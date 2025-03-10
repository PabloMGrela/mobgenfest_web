import 'package:flutter/widgets.dart';
import 'package:mobgenfest/square_text.dart';

List<String> texts = [
  "DJ CARIBE",
  "PULPO",
  "SESIon VERMU",
  "LACoN",
  "CERVEZA",
  "CUBALIBRES",
  "TONGOS",
  "glamping",
  "la ventanita",
  "tirador",
  "camisetas",
  "fotos",
  "fiesta",
  "beerpong",
  "CERVEZA",
  "SESIon VERMU",
  "LACoN",
  "CUBALIBRES",
  "PULPO",
  "SESIon VERMU",
  "LACoN",
  "CERVEZA",
  "TONGOS",
  "CUBALIBRES",
  "TONGOS",
  "SESIon VERMU",
  "PULPO",
  "LACoN",
  "CERVEZA",
  "CUBALIBRES",
  "TONGOS"
];

class AlternatingWrap extends StatelessWidget {
  const AlternatingWrap({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 800),
      child: LayoutBuilder(
        builder: (context, constraints) {
          List<Widget> wrapChildren = [];

          for (int i = 0; i < texts.length; i++) {
            wrapChildren.add(
              OrangeSquareText(
                text: texts[i],
                primary: i % 2 == 0,
              ),
            );
          }

          return Wrap(
            alignment: WrapAlignment.center,
            children: wrapChildren,
          );
        },
      ),
    );
  }
}
