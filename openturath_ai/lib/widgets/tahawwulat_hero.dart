import 'package:flutter/material.dart';
import '../core/localization.dart';
import '../core/scholarly_fonts.dart';
import 'tahawwulat_diagram.dart';

String reviewCopy(String id, String ar, String en) => Loc.isArabic ? ar : Loc.language == 'en' ? en : id;

class TahawwulatHero extends StatelessWidget {
  const TahawwulatHero({super.key, required this.onOpen, required this.onIntroduction, this.facts = const []});
  final VoidCallback onOpen;
  final VoidCallback onIntroduction;
  final List<String> facts;
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
    final wide=box.maxWidth >= 720 && MediaQuery.textScalerOf(context).scale(16) <= 24;
    final text=Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Row(children:[const Icon(Icons.auto_stories_rounded,color:Colors.white70,size:20),const SizedBox(width:10),
        Expanded(child:Text('OpenTurath',style:ScholarlyFonts.outfit(fontSize:14,color:Colors.white70,fontWeight:FontWeight.w600)))]),
      const SizedBox(height:24),
      Text(reviewCopy('Fikih Tahawwulat','فقه التحولات','Fiqh Tahawwulat'),style:ScholarlyFonts.outfit(fontSize:wide?40:30,fontWeight:FontWeight.w600,height:1.15,color:Colors.white)),
      const SizedBox(height:20),
      if(facts.isNotEmpty) Wrap(spacing:16,runSpacing:8,children:[for(final fact in facts) Text(fact,style:ScholarlyFonts.outfit(fontSize:14,color:Colors.white70))]),
      const SizedBox(height:24),
      Wrap(spacing:12,runSpacing:12,children:[
        FilledButton(onPressed:onOpen,style:FilledButton.styleFrom(backgroundColor:Colors.white,foregroundColor:const Color(0xFF171717),padding:const EdgeInsets.symmetric(horizontal:24,vertical:16)),
          child:Text(reviewCopy('Buka Fikih Tahawwulat','افتح فقه التحولات','Open Fiqh Tahawwulat'))),
        TextButton(onPressed:onIntroduction,style:TextButton.styleFrom(foregroundColor:Colors.white,padding:const EdgeInsets.symmetric(horizontal:16,vertical:16)),
          child:Text(reviewCopy('Mengenal Fikih Tahawwulat','تعرّف على فقه التحولات','About Fiqh Tahawwulat'))),
      ]),
    ]);
    return Container(padding:EdgeInsets.all(wide?32:24),decoration:BoxDecoration(color:const Color(0xFF171717),borderRadius:BorderRadius.circular(wide?36:28)),
      child:wide?Row(children:[Expanded(flex:3,child:text),const SizedBox(width:24),const Expanded(flex:2,child:TahawwulatDiagram(inverse:true))]):Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[text,const SizedBox(height:20),const Center(child:SizedBox(width:210,child:TahawwulatDiagram(inverse:true)))]));
  });
}
