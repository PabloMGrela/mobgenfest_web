import 'package:flutter/material.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'FREQUENTLY ASKED QUESTIONS',
            style: TextStyle(
                fontFamily: 'Lab',
                fontSize: 32,
                letterSpacing: 3,
                color: Colors.white),
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              itemCount: faqQuestions.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: ExpansionTile(
                    shape: const RoundedRectangleBorder(side: BorderSide.none),
                    collapsedIconColor: const Color(0xFFFF6600),
                    iconColor: const Color(0xFFFF6600),
                    title: Text(
                      faqQuestions[index].question,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 22,
                        letterSpacing: 0.5,
                      ),
                    ),
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                        child: Text(
                          faqQuestions[index].answer,
                          style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                              height: 1.6,
                              letterSpacing: 0.2),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ));
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
          "Todos. Pero el evento principal tiene lugar el sábado, desde las 12 del mediodía hasta que tú decidas."),
  FAQItem(
      question: "¿Puedo ir sólo un día?",
      answer:
          "Claro, el sábado es la mejor opción si sólo quieres venir un día"),
  FAQItem(
      question: "¿Puedo ir los 3 días?",
      answer:
          "Por supuesto! Como está cerca puedes elegir ir y volver en el día o llevarte tu tienda y quedarte a dormir en la finca."),
  FAQItem(
      question: "¿Si voy los 3 días, qué haremos?", answer: "Pasarlo bien :D"),
  FAQItem(
      question: "¿Dónde es?",
      answer:
          "En Ledoño, al lado de Coruña. Esto permite ir/volver en taxi sin mucha complicación."),
  FAQItem(
      question: "¿Cuánto cuesta?",
      answer:
          "No tenemos un presupuesto cerrado, pero estará en torno a los 45€ por persona."),
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
