# Deployment Guide

## Automatic Deployment

This repository uses GitHub Actions to automatically build and deploy the Flutter web application to GitHub Pages.

### How it works

1. **Trigger**: The deployment workflow runs automatically when:
   - Code is pushed to the `main` branch
   - Manually triggered via the GitHub Actions tab (workflow_dispatch)

2. **Build Process**:
   - Sets up Flutter stable channel
   - Installs dependencies with `flutter pub get`
   - Builds the web app with `flutter build web --release`
   - Preserves the CNAME file for the custom domain (mobgenfest.com)
   - Adds `.nojekyll` file to prevent Jekyll processing

3. **Deployment**:
   - Copies the built files to the `docs/` folder
   - Commits and pushes changes back to the repository
   - GitHub Pages serves the site from the `docs/` folder

### Workflow File

The workflow is defined in `.github/workflows/deploy.yml`

### Manual Deployment

If you need to deploy manually:

1. Build the app locally:
   ```bash
   flutter build web --release --base-href "/"
   ```

2. Copy files to docs folder:
   ```bash
   rm -rf docs/*
   cp -r build/web/* docs/
   cp CNAME docs/CNAME  # If using custom domain
   touch docs/.nojekyll
   ```

3. Commit and push:
   ```bash
   git add docs/
   git commit -m "Manual deployment"
   git push
   ```

## GitHub Pages Configuration

Make sure your repository settings have:
- GitHub Pages enabled
- Source set to "Deploy from a branch"
- Branch set to `main` and folder set to `/docs`

## Custom Domain

The custom domain `mobgenfest.com` is configured via the `docs/CNAME` file.
