// Programa de lectura de puerto serial, para adquirir datos desde arduino y graficarlos.
//Presionando la tecla s se guardan los puntos obtenidos en un documento .txt en la carpeta de instalación de Processing
import processing.serial.*;
import peasy.*;
import java.io.FileWriter;
import java.util.Calendar;
import java.text.SimpleDateFormat;

Serial serial;
PeasyCam cam;
int serialPortNumber = 0;
final float angleIncrement=0.1f;

float h = 0; 

ArrayList<PVector> pointList;

void setup() {
  size(800, 640, P3D);
  colorMode(RGB, 255, 255, 255);
  pointList = new ArrayList<PVector>();
  
  // PeasyCam
  cam = new PeasyCam(this, 800);
  cam.rotateZ(-3.1415/4);
  cam.rotateX(-3.1415/4);
  
  // Serial Port
  try{
    String[] serialPorts = Serial.list();
    println("Serial ports:");
    printArray(serialPorts);
    println("Selected: ["+serialPortNumber+"]");
    String serialPort = serialPorts[serialPortNumber];
    println("Using serial port \"" + serialPort + "\"");
 
    serial = new Serial(this, serialPort, 115200);
  } catch(Exception e){
    println("Not able to connect to serialPort (error:"+e.getClass().getName()+")");
    exit();
  }
}

void draw() {
  // Prepara entorno para dibujo 
  perspective();
  background(33);
  stroke(255,255,255);
  sphere(0.5f);
  fill(50);
  ellipse(0, 0, 10, 10);
  
  //Lectura de Serial 
  String serialString = serial.readStringUntil('\n');
  if (serialString != null) {
    String[] coordinates = split(serialString, ' ');
    if (coordinates.length == 4) {
      pointList.add(new PVector(float(coordinates[0]), float(coordinates[1]), float(coordinates[2])));
      h = float(coordinates[3]); 
    }
  }
 
  // Dibujar puntos 
  for (int index = 0; index < pointList.size(); index++) {
    PVector v = pointList.get(index);
    if (index == pointList.size() - 1) {
      // Dibujar linea desde un origen gasta el punto actual 
      stroke(255, 120, 15);
      line(0, 0, 0, v.x,v.y,v.z);
    }
    // Dibujar punto 
    stroke(255,110+v.z, 0); // elegir color del punto 
    point(v.x, v.y, v.z); // Punto con coordenadas ( X Y Z )
  }
}

// Teclas para guardar los puntos o limpiar la pantalla 
void keyReleased() {
  if (key =='x') {
    // erase all points
    pointList.clear();
  } else if(key == 's'){
    saveToFile();
  }
  else if (key == CODED) {
    if (keyCode == UP) {
      cam.rotateX(angleIncrement);
    } else if (keyCode == DOWN) {
      cam.rotateX(-angleIncrement);
    }else if (keyCode == LEFT) {
      cam.rotateY(angleIncrement);
    }else if (keyCode == RIGHT) {
      cam.rotateY(-angleIncrement);
    }
  }
}

// Función para guardar el arreglo de puntos en el directorio de instalación de processing 
void saveToFile(){
  String fileName = "./points_"+
        new SimpleDateFormat("yyMMdd_HHmmss").format(Calendar.getInstance().getTime())+".txt";
  PrintWriter pw = null;
 
  try{
    pw = new PrintWriter(new FileWriter(fileName,true));
    for(int i=0;i<pointList.size();i++)
      pw.println((int)pointList.get(i).x + " " + 
                  (int)pointList.get(i).y + " " +
                  (int)pointList.get(i).z);
  }
  catch(Exception e){
  }
  finally 
  {
    if(pw != null) pw.close();
  }
}
