import gifAnimation.*;

import megamu.mesh.*;

import netP5.*;
import oscP5.*;
import processing.serial.*;

PApplet sketch;

int start = millis();

ArrayList<Thing> things = new ArrayList<Thing>();
ArrayList<String> messages = new ArrayList<String>();
ADGettext line;
int max_messages = 5;


void setup() {
  sketch = this;
  size(600,600);
  line = new ADGettext(20,height-50,500,"> ","fname");
  line.setFocusOn();
}

void draw() {
  background(255);
  setNeighbours();
  for (Thing thing : things) {
    thing.move();
    thing.draw();
  }
  
  float[][] edges = thingEdges();
  for (float[] coords : edges) {
    line(coords[0], coords[1], coords[2], coords[3]);
  }
  line.update();
  
  textFont(line.gText,20);
  textAlign(LEFT);
  int i = 0;
  int msggap = 25;
  int top = height-(40 + (25*messages.size()));
  for (String message : messages) {
    fill((255/max_messages)*(messages.size()-i));  
    text(message,20,top+(25*i));
    i++;
  }
}

Thing find(String name) {
  Thing result = null;
  for (Thing thing : things) {
    println("check " + thing.name);
    if (thing.name.equals(name)) {
      result = thing;
      break;
    }
  }
  return(result);
}

Delaunay thingDelaunay() {
  float[][] points = new float[things.size()][2];
  int i = 0;
  for (Thing thing : things) {
    points[i][0] = thing.v.x;
    points[i][1] = thing.v.y;
    ++i;
  }
  Delaunay d = new Delaunay(points);
  return(d);
}

float[][] thingEdges() {
  float[][] result;
  Delaunay d = thingDelaunay();
  result = d.getEdges();
  return(result);
}

int[][] thingLinks() {
  Delaunay d = thingDelaunay();
  int[][] result = d.getLinks();
  return(result);
}

void setNeighbours() {
  int[][] links = thingLinks();
  for (Thing thing : things) {
    thing.neighbours.clear();
  }
  for (int i = 0; i < links.length; ++i) {
    if (links[i][0] == links[i][1]) {
      continue;
    }
    //println("link from " + links[i][0] + " to " + links[i][1]);
    Thing from = things.get(links[i][0]);
    Thing to = things.get(links[i][1]);
    // println("neighbour " + from.name + " <> " + to.name);
    from.neighbours.add(to);
    to.neighbours.add(from);
  }
}

String _thing(String[] tokens) {
  String result = "?";

  if (tokens.length > 1) {
    String name = tokens[1];
    if (find(name) != null) {
      result = name + " is already here.";
    }
    else {
      things.add(new Thing(name));
      result = name + " arrives.";
    }
  }
  else {
    result = "Please give the thing a name";
  }
  return(result);
}

void command(String cmd) {
  String[] tokens = splitTokens(cmd);
  String result = "";
  if (tokens.length == 0) {
    return;
  }
  switch (tokens[0]) {
    case "thing": result = _thing(tokens); break;
  }
  messages.add(result);
  if (messages.size() > max_messages) {
    messages.remove(0);
  }
  print(result + "\n");
}

void keyPressed() {
  int i = line.checkKeyboardInput();
  if (i == 1000) {
    command(line.getText());
    line.eraseField();
  }
}

void keyReleased() {
  line.checkAdditionalKeys();
}