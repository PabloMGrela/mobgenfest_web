import 'package:flutter/material.dart';

class LegalScreen extends StatelessWidget {
  final bool showPrivacy;
  const LegalScreen({super.key, this.showPrivacy = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: Text(
          showPrivacy ? "Politica de Privacidad" : "Terminos y Condiciones",
          style:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              showPrivacy ? "Politica de Privacidad" : "Terminos y Condiciones",
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter', // Default system sans-serif
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Ultima actualizacion: Enero 2026",
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 32),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (showPrivacy) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LegalSection(
            title: "1. Recogida de Datos",
            content:
                "Recopilamos la informacion que nos proporcionas directamente al registrarte para el MOBGEN FEST 2026, incluyendo tu nombre, correo electronico, numero de telefono, restricciones alimenticias y foto de perfil.",
          ),
          _LegalSection(
            title: "2. Uso de la Informacion",
            content:
                "Tus datos se utilizan exclusivamente para la organizacion del festival, incluyendo identificacion, comunicacion sobre el pago y distribucion de grupos.",
          ),
          _LegalSection(
            title: "3. Derechos de Imagen",
            content:
                "Al asistir al evento, aceptas que las fotos o videos tomados durante el festival puedan ser utilizados por los organizadores para fines internos o promocionales.",
          ),
          _LegalSection(
            title: "4. Retencion de Datos",
            content:
                "Mantendremos tu informacion personal solo durante el tiempo necesario para los fines establecidos en esta Politica de Privacidad.",
          ),
        ],
      );
    } else {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LegalSection(
            title: "1. Registro y Pago",
            content:
                "El registro es personal e intransferible. La fecha limite de pago es el 31 de marzo de 2026. El impago en esta fecha resultara en la cancelacion del registro.",
          ),
          _LegalSection(
            title: "2. EXENCION DE RESPONSABILIDAD Y ASUNCION DE RIESGOS",
            content:
                "AL REGISTRARTE PARA EL MOBGEN FEST 2026, RECONOCES QUE LA PARTICIPACION EN EL EVENTO IMPLICA RIESGOS INHERENTES. ASUMES VOLUNTARIAMENTE TODOS LOS RIESGOS RELACIONADOS CON LA EXPOSICION A LESIONES FISICAS, ACCIDENTES U OTROS EVENTOS IMPREVISTOS.",
          ),
          _LegalSection(
            title: "3. AUSENCIA DE RESPONSABILIDAD DE LOS ORGANIZADORES",
            content:
                "EN EL CASO DE ACCIDENTE, LESION O CUALQUIER PERDIDA SUFRIDA DURANTE EL FESTIVAL, ACEPTAS QUE LA RESPONSABILIDAD TOTAL RECAE EN EL PARTICIPANTE INDIVIDUAL. LOS ORGANIZADORES, EL PERSONAL Y LOS AFILIADOS NO SERAN RESPONSABLES POR NINGUN DAÑO, GASTO MEDICO O RECLAMACION LEGAL DERIVADA DE TU PARTICIPACION EN EL EVENTO.",
          ),
          _LegalSection(
            title: "4. Conducta",
            content:
                "Los organizadores se reservan el derecho de denegar la entrada o retirar a cualquier participante cuya conducta se considere inapropiada o perjudicial para el entorno del evento.",
          ),
        ],
      );
    }
  }
}

class _LegalSection extends StatelessWidget {
  final String title;
  final String content;
  const _LegalSection({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
