import json
import urllib.request
import urllib.parse
import ssl
import math

# Configuration
try:
    from secrets import API_KEY
except ImportError:
    import os

    API_KEY = os.environ.get("GOOGLE_PLACES_API_KEY", "")
    if not API_KEY:
        print("Warning: API_KEY not found in secrets.py or environment variables.")
OFFICE_LAT = 43.367870
OFFICE_LNG = -8.403319
JSON_FILE_PATH = "assets/data/restaurants.json"
REFERER = "https://www.mobgenfest.com"

SPECIFIC_PLACES = [
    "Ártabro bar",
    "Restaurante Detomas",
    "Parrillada Alcume",
]

# Added places.photos
FIELD_MASK = "places.displayName,places.formattedAddress,places.priceLevel,places.rating,places.userRatingCount,places.location,places.regularOpeningHours,places.photos,places.nationalPhoneNumber"


def create_ssl_context():
    context = ssl.create_default_context()
    context.check_hostname = False
    context.verify_mode = ssl.CERT_NONE
    return context


def make_request(url, data=None):
    req = urllib.request.Request(url)
    req.add_header("Referer", REFERER)
    req.add_header("Content-Type", "application/json")
    req.add_header("X-Goog-Api-Key", API_KEY)

    if data:
        req.add_header("X-Goog-FieldMask", FIELD_MASK)
        data_bytes = json.dumps(data).encode("utf-8")
    else:
        data_bytes = None

    try:
        with urllib.request.urlopen(
            req, data=data_bytes, context=create_ssl_context()
        ) as response:
            if response.status != 200:
                print(f"Request failed: {response.status}")
                return None
            return json.loads(response.read().decode("utf-8"))
    except Exception as e:
        print(f"Error: {e}")
        return None


def fetch_text_search(query):
    url = "https://places.googleapis.com/v1/places:searchText"
    data = {
        "textQuery": query,
        "locationBias": {
            "circle": {
                "center": {"latitude": OFFICE_LAT, "longitude": OFFICE_LNG},
                "radius": 2000.0,
            }
        },
        "maxResultCount": 1,
    }
    return make_request(url, data)


def fetch_nearby_search():
    url = "https://places.googleapis.com/v1/places:searchNearby"
    data = {
        "includedTypes": ["restaurant"],
        "maxResultCount": 20,
        "locationRestriction": {
            "circle": {
                "center": {"latitude": OFFICE_LAT, "longitude": OFFICE_LNG},
                "radius": 600.0,
            }
        },
    }
    return make_request(url, data)


def sanitize_filename(name):
    return (
        "".join(c for c in name if c.isalnum() or c in (" ", "_", "-"))
        .rstrip()
        .replace(" ", "_")
        .lower()
    )


def process_photos(places):
    import os

    images_dir = "assets/images/restaurants"
    if not os.path.exists(images_dir):
        os.makedirs(images_dir)

    print(f"Processing photos for {len(places)} places...")

    for place in places:
        photos = place.get("photos", [])
        if photos:
            # Take the first photo
            first_photo = photos[0]
            resource_name = first_photo.get("name")
            if resource_name:
                # Construct the API URL
                api_url = f"https://places.googleapis.com/v1/{resource_name}/media?maxHeightPx=400&maxWidthPx=500&key={API_KEY}"

                # Generate local filename
                place_name = place["displayName"]["text"]
                filename = f"{sanitize_filename(place_name)}.jpg"
                local_path = f"{images_dir}/{filename}"

                print(f"Downloading photo for {place_name}...")

                try:
                    # Download the image
                    req = urllib.request.Request(api_url)
                    req.add_header("Referer", REFERER)

                    with urllib.request.urlopen(
                        req, context=create_ssl_context()
                    ) as response:
                        if response.status == 200:
                            with open(local_path, "wb") as f:
                                f.write(response.read())

                            # Update JSON with local asset path
                            place["photoUrl"] = local_path
                            print(f"  Saved to {local_path}")
                        else:
                            print(f"  Failed to download: Status {response.status}")
                except Exception as e:
                    print(f"  Error downloading photo: {e}")

            # Remove raw photo data to keep JSON clean but keep structure if needed
            # We keep 'photos' key as is for now in case we need it later

    return places


def calculate_haversine_distance(places):
    print(
        f"Calculating estimated walking distances for {len(places)} places via Haversine..."
    )
    R = 6371e3  # Earth radius in meters

    for place in places:
        lat1 = OFFICE_LAT
        lon1 = OFFICE_LNG
        lat2 = place["location"]["latitude"]
        lon2 = place["location"]["longitude"]

        phi1 = lat1 * math.pi / 180
        phi2 = lat2 * math.pi / 180
        dphi = (lat2 - lat1) * math.pi / 180
        dlambda = (lon2 - lon1) * math.pi / 180

        a = (
            math.sin(dphi / 2) ** 2
            + math.cos(phi1) * math.cos(phi2) * math.sin(dlambda / 2) ** 2
        )
        c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
        d = R * c  # Straight line distance in meters

        # Estimate walking distance (factor 1.3)
        walking_dist = d * 1.3

        # Walking speed estimate ~5 km/h = ~83 m/min or ~1.4 m/s
        walking_mins = walking_dist / 80.0

        formatted_dist = f"{int(walking_dist)} m"
        if walking_dist > 1000:
            formatted_dist = f"{walking_dist / 1000:.1f} km"

        formatted_dur = f"{int(walking_mins)} min"

        place["distanceText"] = formatted_dist
        place["durationText"] = formatted_dur

    return places


def main():
    all_places_map = {}

    # 1. Fetch Specific Places
    print("Fetching specific places...")
    for name in SPECIFIC_PLACES:
        res = fetch_text_search(name)
        if res and "places" in res:
            for p in res["places"]:
                print(f"Found: {p['displayName']['text']}")
                all_places_map[p["displayName"]["text"]] = p
        else:
            print(f"Could not find: {name}")

    # 2. Fetch Nearby High Rated
    print("Fetching nearby places (< 600m)...")
    res = fetch_nearby_search()
    if res and "places" in res:
        for p in res["places"]:
            rating = p.get("rating", 0)
            if rating > 4.0:
                all_places_map[p["displayName"]["text"]] = p

    # Convert map to list
    final_places = list(all_places_map.values())
    print(f"Total unique places found: {len(final_places)}")

    # 3. Process Photos
    final_places = process_photos(final_places)

    # 4. Calculate Distances (Haversine)
    final_places = calculate_haversine_distance(final_places)

    # 5. Save
    output = {"places": final_places}
    with open(JSON_FILE_PATH, "w") as f:
        json.dump(output, f, indent=2, ensure_ascii=False)

    print(f"Saved to {JSON_FILE_PATH}")


if __name__ == "__main__":
    main()
