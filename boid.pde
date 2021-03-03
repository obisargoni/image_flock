/* The Image Block Boid Class

Extends the boid class in order to link a block of pixels in an image to a boid and rended these pixels when drawing the boid.
*/
class ImgBlockBoid extends Boid<ImgBlockBoid> {
  
  PImage img;
  int[] imageCoord = new int[2];
  int nx;
  int ny;
  
  ImgBlockBoid(int x, int y, int ix, int iy, int w, int h, PImage pi) {
    super((float)x, (float)y);
    imageCoord[0] = ix;
    imageCoord[1] = iy;
    nx = w;
    ny = h;
    img = pi;
  }
  
  /*
  Draw the pixels assigned to this image block at the boid location
  */
  void renderExact() {
    loadPixels();
    img.loadPixels();
    
    // Loop through image pixel locations assigned to this block and draw in new position
    for (int y = 0; y < ny; y++) {
      for (int x = 0; x < nx; x++) {
        int canvasX = x+(int)position.x;
        int canvasY = y+(int)position.y;
        
        // Check that location is on canvas, don't draw if out of range
        if ((0<=canvasX) & (canvasX<width) & (0<=canvasY) & (canvasY<height)) {
          int imgloc = (x+imageCoord[0]) + (y+imageCoord[1])*img.width;
          int canvasloc = (canvasX) + (canvasY)*width;
          pixels[canvasloc] = img.pixels[imgloc];
        }
      }
    }
    updatePixels();
  }
  
  /*
  Render each boid as a circle of uniform colour takes from a sample of the corresponding pixels
  */
  void render() {
    img.loadPixels();
    
    // No need to loop through all coordinates
    
    // If location is on canvas render boid as circle here
    if ((0<=position.x) & (position.x<width) & (0<=position.y) & (position.y<height)) {
      
      // Get colour of image near this location (at centre of where the circle will be)
      color c = img.get(nx/2 + imageCoord[0], ny/2 + imageCoord[1]);
      fill(c);
      noStroke();
      ellipse(position.x, position.y, nx, ny);
    }
  }
}

// The Boid class

class Boid<T extends Boid> {

  PVector position;
  PVector velocity;
  PVector acceleration;
  float r;
  float maxforce;    // Maximum steering force
  float maxspeed;    // Maximum speed

    Boid(float x, float y) {
    acceleration = new PVector(0, 0);

    // This is a new PVector method not yet implemented in JS
    // velocity = PVector.random2D();

    // Leaving the code temporarily this way so that this example runs in JS
    float angle = random(TWO_PI);
    velocity = new PVector(cos(angle), sin(angle));

    position = new PVector(x, y);
    r = 2.0;
    maxspeed = 2;
    maxforce = 0.03;
  }

  void run(ArrayList<T> boids) {
    flock(boids);
    update();
    borders();
    render();
  }

  void applyForce(PVector force) {
    // We could add mass here if we want A = F / M
    acceleration.add(force);
  }

  // We accumulate a new acceleration each time based on three rules
  void flock(ArrayList<T> boids) {
    PVector sep = separate(boids);   // Separation
    PVector ali = align(boids);      // Alignment
    PVector coh = cohesion(boids);   // Cohesion
    // Arbitrarily weight these forces
    sep.mult(1.5);
    ali.mult(1.0);
    coh.mult(1.0);
    // Add the force vectors to acceleration
    applyForce(sep);
    applyForce(ali);
    applyForce(coh);
  }

  // Method to update position
  void update() {
    // Update velocity
    velocity.add(acceleration);
    // Limit speed
    velocity.limit(maxspeed);
    position.add(velocity);
    // Reset accelertion to 0 each cycle
    acceleration.mult(0);
  }

  // A method that calculates and applies a steering force towards a target
  // STEER = DESIRED MINUS VELOCITY
  PVector seek(PVector target) {
    PVector desired = PVector.sub(target, position);  // A vector pointing from the position to the target
    // Scale to maximum speed
    desired.normalize();
    desired.mult(maxspeed);

    // Above two lines of code below could be condensed with new PVector setMag() method
    // Not using this method until Processing.js catches up
    // desired.setMag(maxspeed);

    // Steering = Desired minus Velocity
    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxforce);  // Limit to maximum steering force
    return steer;
  }

  void render() {
    // Draw a triangle rotated in the direction of velocity
    float theta = velocity.heading2D() + radians(90);
    // heading2D() above is now heading() but leaving old syntax until Processing.js catches up
    
    fill(200, 100);
    stroke(255);
    pushMatrix();
    translate(position.x, position.y);
    rotate(theta);
    beginShape(TRIANGLES);
    vertex(0, -r*2);
    vertex(-r, r*2);
    vertex(r, r*2);
    endShape();
    popMatrix();
  }

  // Wraparound
  void borders() {
    if (position.x < 0) position.x = width;
    if (position.y < -r) position.y = height;
    if (position.x > width) position.x = 0;
    if (position.y > height) position.y = 0;
  }

  // Separation
  // Method checks for nearby boids and steers away
  PVector separate (ArrayList<T> boids) {
    float desiredseparation = 25.0f;
    PVector steer = new PVector(0, 0, 0);
    int count = 0;
    // For every boid in the system, check if it's too close
    for (Boid other : boids) {
      float d = PVector.dist(position, other.position);
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d > 0) && (d < desiredseparation)) {
        // Calculate vector pointing away from neighbor
        PVector diff = PVector.sub(position, other.position);
        diff.normalize();
        diff.div(d);        // Weight by distance
        steer.add(diff);
        count++;            // Keep track of how many
      }
    }
    // Average -- divide by how many
    if (count > 0) {
      steer.div((float)count);
    }

    // As long as the vector is greater than 0
    if (steer.mag() > 0) {
      // First two lines of code below could be condensed with new PVector setMag() method
      // Not using this method until Processing.js catches up
      // steer.setMag(maxspeed);

      // Implement Reynolds: Steering = Desired - Velocity
      steer.normalize();
      steer.mult(maxspeed);
      steer.sub(velocity);
      steer.limit(maxforce);
    }
    return steer;
  }

  // Alignment
  // For every nearby boid in the system, calculate the average velocity
  PVector align (ArrayList<T> boids) {
    float neighbordist = 50;
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (Boid other : boids) {
      float d = PVector.dist(position, other.position);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.velocity);
        count++;
      }
    }
    if (count > 0) {
      sum.div((float)count);
      // First two lines of code below could be condensed with new PVector setMag() method
      // Not using this method until Processing.js catches up
      // sum.setMag(maxspeed);

      // Implement Reynolds: Steering = Desired - Velocity
      sum.normalize();
      sum.mult(maxspeed);
      PVector steer = PVector.sub(sum, velocity);
      steer.limit(maxforce);
      return steer;
    } 
    else {
      return new PVector(0, 0);
    }
  }

  // Cohesion
  // For the average position (i.e. center) of all nearby boids, calculate steering vector towards that position
  PVector cohesion (ArrayList<T> boids) {
    float neighbordist = 50;
    PVector sum = new PVector(0, 0);   // Start with empty vector to accumulate all positions
    int count = 0;
    for (Boid other : boids) {
      float d = PVector.dist(position, other.position);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.position); // Add position
        count++;
      }
    }
    if (count > 0) {
      sum.div(count);
      return seek(sum);  // Steer towards the position
    } 
    else {
      return new PVector(0, 0);
    }
  }
}
