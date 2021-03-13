Flock flock;
ImgBlockBoid ibb;
PImage img;
PImage flockImg;
int resizeFactor = 3;

void setup() {
  size(1053, 237);
  
  img = loadImage("IMG_0086.JPG");
  //float resizedWidth = img.width  ( width / img.width);
  //int resizedWidth = round(img.width / resizeFactor);
  img.resize(width, 0);
  
  flockImg = loadImage("8-85316_walking-icon.jpg");
  flockImg.resize( flockImg.width / resizeFactor, 0);

  // Create an image block boid flock
  flock = new Flock(flockImg, 10, 10);
}

void draw() {
  image(img, 0, 0);
  flock.run();
}

// Add a new boid into the System
void mousePressed() {
  //flock.addBoid(new Boid(mouseX,mouseY));
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
