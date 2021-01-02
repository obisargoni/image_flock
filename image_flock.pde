Flock flock;
ImgBlockBoid ibb;
PImage img;
int resizeFactor = 3;

void setup() {
  size(1280, 720);
  
  img = loadImage("obipic.jpg");
  int resizedWidth = img.width / resizeFactor;
  print(img.width);
  img.resize(resizedWidth, 0);
  print(img.width);
  print(resizedWidth);
  flock = new Flock();
  // Add an initial set of boids into the system
  for (int i = 0; i < 150; i++) {
    flock.addBoid(new Boid(width/2,height/2));
  }
  
  ibb = new ImgBlockBoid(0.0, 0.0, 0, 0, 10, 10, img);
  
}

void draw() {
  background(50);
  image(img, 0, 0);
  //flock.run();
  ibb.render();
  PVector d = new PVector(1,0);
  ibb.position.add(d);
}

// Add a new boid into the System
void mousePressed() {
  flock.addBoid(new Boid(mouseX,mouseY));
}



// The Flock (a list of Boid objects)

class Flock {
  ArrayList<ImgBlockBoid> boids; // An ArrayList for all the boids

  Flock(PImage img, int blockWidth, int blockHeight) {
    boids = new ArrayList<ImgBlockBoid>(); // Initialize the ArrayList
    
    int cumBlockWidth = 0;
    int cumBlockHeight = 0;
    
    while (cumBlockHeight < img.height) {
      // Controls for number of pixels in image not dividing equally into blocks of height blockHeight
      int bh = min(blockHeight, img.height - cumBlockHeight);

      while (cumBlockWidth < img.width) {
        
        // Controls for number of pixels in image not dividing equally into blocks of width blockWidth
        int bw = min(blockWidth, img.width - cumBlockWidth);
        
        ImgBlockBoid ibb = new ImgBlockBoid(cumBlockWidth, cumBlockHeight, cumBlockWidth, cumBlockHeight, bw, bh, img);
        boids.add(ibb);
        
        cumBlockWidth += bw;
      }
      cumBlockWidth = 0;
      cumBlockHeight += bh;
    }   
    
  }

  void run() {
    for (Boid b : boids) {
      b.run(boids);  // Passing the entire list of boids to each boid individually
    }
  }

  void addBoid(ImgBlockBoid b) {
    boids.add(b);
  }
  
  ImgBlockBoid get(int i) {
    return boids.get(i);
  }
}
