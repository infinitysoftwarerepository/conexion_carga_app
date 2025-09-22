import 'package:flutter/material.dart';

class CounterFunctionsScreen extends StatefulWidget {

  
  const CounterFunctionsScreen({super.key});

  @override
  State<CounterFunctionsScreen> createState() => _CounterFunctionsScreenState();
}

class _CounterFunctionsScreenState extends State<CounterFunctionsScreen> {

int clickCounter = 0;

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: const Text('CONEXIÓN CARGA',
          style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFFF0890C),
        centerTitle: true, 
        actions: [

          IconButton(
          icon: Icon( Icons.refresh_rounded),
          onPressed: () {
            setState((){
              clickCounter = 0;
            });
          }),

        ]
          

        ),
      body: Column(
  children: [
    // Imagen en la parte superior
    Image.asset(
      'assets/images/logo_conexion_carga_V1.png', // Ajusta el nombre
      fit: BoxFit.cover, // Ajusta la imagen al espacio
      height: 200, // Altura deseada (ajusta según necesites)
      width: double.infinity, // Ocupa todo el ancho
    ),
    // Resto del contenido (contador)
    Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$clickCounter',
            style: const TextStyle(fontSize: 160, fontWeight: FontWeight.w100),
          ),
          Text(
            'Viaje${clickCounter == 1 ? '' : 's'}',
            style: const TextStyle(fontSize: 25),
          ),
        ],
      ),
    ),
  ],
),
      floatingActionButton: Column(

        mainAxisAlignment: MainAxisAlignment.end ,
        children: [

          CustonButton( 
            icon: Icons.refresh_rounded,
            onPressed: () {
              clickCounter = 0;
              setState ((){});
            
            },
            color: Colors.grey
          ),
          const SizedBox ( height: 10),
          CustonButton( icon: Icons.plus_one,
                      onPressed:  () {
              clickCounter ++;
              setState ((){});
            },
           color: Color(0xFF77AD40) 
           ),  
          const SizedBox ( height: 10),
          
          CustonButton( 
            icon: Icons.exposure_minus_1_outlined,
            
            onPressed:  () {
              if (clickCounter == 0) return;
              clickCounter --;
              setState ((){});
              
            },
            color: Color(0xFFFFC000),
          ),

        ],
       )
    );
  }
}

class CustonButton extends StatelessWidget {

final IconData icon;
final VoidCallback? onPressed;
final Color? color;

  const CustonButton({
    super.key, 
    required this.icon,
    this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      enableFeedback:true,
      elevation: 5,
      backgroundColor: color ?? Colors.deepOrange,
      onPressed: onPressed,
      child: Icon(icon),
     );
  }
}