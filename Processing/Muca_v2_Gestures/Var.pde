import processing.serial.*;
import gab.opencv.*;
import blobDetection.*;
import org.opencv.imgproc.Imgproc;
import org.opencv.core.Mat;
import org.opencv.core.Size;
import java.awt.Rectangle;

Serial myPort;
PGraphics pg, raw;
OpenCV opencv;
OpenCV opencv2;
PImage img, background;
PImage scaledbc;
ArrayList<Contour> contours;
ArrayList<Rectangle> rects;
ArrayList<PVector> vecs;

int[] rawData;
int[][] data;
int[][] calib;
float pxW, pxH;

int row = 12;
int column = 21;
int iF = 30;
int paraNum = row*column;
int minValue = -50; 
int maxValue = 0;
int threshold = 50;


boolean bCalibed = false;
boolean bEngaged = false;

float d0, theta0;
PVector m0;

float scale = 1;
float rotation = 0;
PVector translation = new PVector(0, 0);
String lastGestureInfo = "";
TouchManager tm;
int textSizeL=24;
int textSizeM=20;


final int UNDEFINED = 0;
final int SCALING = 1;
final int ROTATION = 2;
final int TRANSLATION = 3;
int gestureType = 0;
int numFingers = 0;
float d = 0;
float theta = 0;
PVector m = new PVector(0,0);
boolean gesturePerformed = false; 
String info = "";
