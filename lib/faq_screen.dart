import 'package:flutter/material.dart';
import 'package:mobgenfest/constants.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.brandDark,
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppConstants.brandOrange.withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppConstants.brandSecondary.withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: const BackButton(color: Colors.white),
                expandedHeight: 200,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: const Text(
                    'PREGUNTAS FRECUENTES',
                    style: TextStyle(
                      fontFamily: 'Lab',
                      fontSize: 24,
                      letterSpacing: 4,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  background: Center(
                    child: Opacity(
                      opacity: 0.1,
                      child: Icon(Icons.help_outline,
                          size: 150, color: AppConstants.brandOrange),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                sliver: SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: Column(
                        children: faqQuestions
                            .map((item) => _FAQExpansionTile(item: item))
                            .toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FAQExpansionTile extends StatelessWidget {
  final FAQItem item;
  const _FAQExpansionTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          collapsedIconColor: AppConstants.brandOrange,
          iconColor: AppConstants.brandOrange,
          tilePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          title: Text(
            item.question,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 20,
              letterSpacing: 0.5,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  item.answer,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 17,
                    height: 1.6,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});
}

final faqQuestions = [
  FAQItem(
      question: "¿Qué es el MobgenFest?",
      answer:
          "Es el mayor evento del año donde nos juntamos compañeros y ex-compañeros para divertirnos y no hablar de trabajo."),
  FAQItem(
      question: "¿Cuál es el día bueno?",
      answer:
          "Todos. Pero el evento principal tiene lugar el sábado 30 de Mayo, desde las 12 del mediodía hasta que tú decidas."),
  FAQItem(
      question: "¿Puedo ir sólo un día?",
      answer:
          "Claro, el sábado es la mejor opción si sólo quieres venir un día."),
  FAQItem(
      question: "¿Puedo ir los 3 días?",
      answer:
          "¡Por supuesto! Como está cerca puedes elegir ir y volver en el día o llevarte tu tienda y quedarte a dormir en la finca."),
  FAQItem(
      question: "¿Si voy los 3 días, qué haremos?", answer: "Pasarlo bien :D"),
  FAQItem(
      question: "¿Dónde es?",
      answer:
          "En Ledoño, al lado de Coruña. Esto permite ir/volver en taxi sin mucha complicación."),
  FAQItem(
      question: "¿Cuánto cuesta?",
      answer:
          "El precio varía según la entrada: Early Bird 50€, General 60€ y VIP 120€."),
  FAQItem(
      question: "¿Qué está incluído en el precio?",
      answer:
          "Cerveza, vermú, vino, la comida y la cena del sábado, además del DJ, juegos y demás actividades que se hagan."),
  FAQItem(
      question: "¿Hay sitio para dormir?",
      answer:
          "Sí, este año habilitamos zona para acampar por 5€ por tienda. No cabemos todos dentro de la casa."),
  FAQItem(
      question: "¿Hay sitio para aparcar?",
      answer: "Sí, hay sitio, pero si bebes, no conduzcas."),
  FAQItem(
      question: "¿Hay que llevar bañador?",
      answer:
          "Piscina no hay, pero si te hace ilusión te damos un manguerazo."),
  FAQItem(
      question: "¿Habrá fuegos artificiales?",
      answer: "No, Nacho, no puedes tirar fuegos artificiales."),
];
