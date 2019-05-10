#include <Servo.h>
#include <Wire.h>
#include <LIDARLite.h>
#include <Stepper.h>


//Delay entre muestras para evitar malas lecturas por movimientos mecanicos
#define Delay_S 10
//Tamaño de pasos
#define A_Pasos 1 //x
#define A_Servo 1 //y
#define M_PI 3.1416
//Comentario
//Variables  
const int stepsPerRevolution=200; //Pasos por vuelta
LIDARLite LIDAR;
Servo servo_y;
Stepper myStepper(stepsPerRevolution,8,9,10,11);
int MotorStep = 0,AnguloServo = 0;
float x,y,z,h,LP = 0;

void setup()
{
  // Iniciar serial
  Serial.begin(115200);
  //RPM Motor a Pasos
  myStepper.setSpeed(150);
  //Servo
  servo_y.attach(12);
  servo_y.write(0);
  altura();
  //Lidar Lite v3
  LIDAR.begin(0, true);
  LIDAR.configure(0);


}
//Loop principal hace girar el motor a pasos un número determindao de veces y luego regresa.
void loop()
{
  delay(1000);
    for (MotorStep = 0; MotorStep <= 120;MotorStep+= 1)
     {
        if(AnguloServo < 90)
        {
          for (AnguloServo = 0; AnguloServo <= 90;AnguloServo+= A_Servo)
          {
            servo_y.write(AnguloServo);
            medir_LIDAR();
          }
        }
        else
        {
          for (AnguloServo = 90; AnguloServo >= 0;AnguloServo-= A_Servo)
          {
            servo_y.write(AnguloServo);
            medir_LIDAR();
          }
        }
        myStepper.step(stepsPerRevolution/A_Pasos);
        LP = LP + 0.75;
     }
    for (MotorStep = 120; MotorStep >= 0;MotorStep-= 1)
     {
       if(AnguloServo < 90)
        {
          for (AnguloServo = 0; AnguloServo <= 90;AnguloServo+= A_Servo)
          {
            servo_y.write(AnguloServo);
            medir_LIDAR();
          }
        }
       else
        {
          for (AnguloServo = 90; AnguloServo >= 0;AnguloServo-= A_Servo)
          {
            servo_y.write(AnguloServo);
            medir_LIDAR();
          }
        }
        myStepper.step(-stepsPerRevolution/A_Pasos);
        LP = LP - 0.75;
     }
}

// Function para adquirir y mandar datos a serial
void medir_LIDAR()
{

  if(AnguloServo >= 0 && AnguloServo <= 45)
    {
        delay(Delay_S);
        x = LP ;
        y = (LIDAR.distance(false) * abs(sin((45-AnguloServo)*(M_PI/180))));
        z = (LIDAR.distance(false) * abs(cos((45-AnguloServo)*(M_PI/180))));
        // Dar formato y enviar a serial
        Serial.println(String(x)+ " " + String(y) + " " + String(z));
    }
  if(AnguloServo > 45 && AnguloServo<= 90)
    {
        delay(Delay_S);
        x = LP ;
        y = (LIDAR.distance(false) * abs(sin((AnguloServo-45)*(M_PI/180))));
        z = (LIDAR.distance(false) * abs(cos((AnguloServo-45)*(M_PI/180))));
        // Dar formato y enviar a serial
        Serial.println(String(x)+ " " + String(y) + " " + String(z));

    }
}
//funcion para leer altura inicial del LIDAR
void altura()
{
  servo_y.write(45);
  delay(500);
  h = LIDAR.distance(false);
  servo_y.write(0);
}
