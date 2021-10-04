/*
 * A little program to create H and V ramps, display them, and combine them.
 *
 * Keep reading for more details...
 *  ...or just run this and press some keys and click on some things to play around.
 * 
 * A little program to create H and V ramps, display them, and combine them.
 * I made this so I could visualize some things a bit better. The interface isn't
 * perfect but it works. I tried giving inputs thin borders and outputs (displays)
 * thick borders, kind of following LZX module labels, sort of. Besides the
 * thin-bordered elements you can click/drag/draw, there are keyboard actions:
 * 
 * Misc Key  Action
 * --------  ------
 *   ?         Toggle help display
 *   !         Randomize all settings, make some random ramps
 *  space      Reset all settings to default
 *
 * H ramp key  V ramp key  Action
 * ----------  ----------  ------
 *   1           q           Set ramp to a linear rising ramp, from 0 to the max
 *   2           w           Set ramp to a sine (cosine really) curve
 *   3           e           Set ramp to lower frequency perlin noise
 *   4           r           Set ramp to higher frequency perlin noise
 *   5           t           Set ramp to random walk noise
 *   6           y           Set ramp to completely random noise
 *   7           u           n/a
 *   8           i           n/a
 *   9           o           Set entire ramp to constant max value (100% white)
 *   0           p           Set entire ramp to constant min value (100% black)
 *
 *   !           Q           Average current ramp with a linear rising ramp
 *   @           W           Average current ramp with a sine (cosine really) curve
 *   #           E           Average current ramp with lower frequency perlin noise
 *   $           R           Average current ramp with higher frequency perlin noise
 *   %           T           Average current ramp with random walk noise
 *   ^           Y           Average current ramp with completely random noise
 *   &           U           n/a
 *   *           I           n/a
 *   (           O           Average current ramp with constant max value
 *   )           P           Average current ramp with constant min value
 *
 *   a           z           Invert ramp
 *   A           Z           Reverse ramp
 *   s           x           Double the frequency of the ramp
 *   d           c           Double the frequency of the first half then mirror it for second half
 *   f           v           Adds a little bit of noise to the ramp
 *   g           b           Scale ramp so the lowest value is 0 and highest is the_size
 *   h           n           n/a
 *   j           m           n/a
 *
 * Debug Key  Action
 * ---------  ------
 *   '         Prints the V ramp to console
 *   "         Same as ' but with each value on their own line
 *   .         Prints only the first two and last two values from V ramp to console
 *   ;         Prints the H ramp to console
 *   :         Same as : but with each value on their own line
 *   /         Prints only the first two and last two values from H ramp to console
 *
 *
 * TIPS/NOTES:
 *
 * - The V ramp is oriented with a 90 degree rotation from the H ramp, so that it lines
 *   up vertically similarly to the way the H ramp lines up horizontally.
 *
 * - If you have too many skipped parts when drawing a ramp, try moving the mouse
 *   at a different speed. Some speeds are smoother, and sometimes faster is better.
 *
 * - If it's too big for your screen or too slow for you computer, shrinking the value
 *   of 'the_size' variable will help. It's the very first variable in the code below.
 *   (You can make it bigger too, but then you'll probably want to adjust the size()
 *   in the setup area.)
 *
 */

// Adjust the following line if necessary (default value is 256):
final int the_size = 256;

int[] h_data = new int[the_size];
int[] v_data = new int[the_size];

int h_input_x = 20;
int h_input_y = 20;
int h_output_x = 20;
int h_output_y = 20+20+the_size;

int v_input_x = 20+40+20+the_size+the_size;
int v_input_y = 20+20+the_size+40+the_size;
int v_output_x = 20+40+the_size;
int v_output_y = 20+20+the_size+40+the_size;

int hv_output_x = h_output_x;
int hv_output_y = v_output_y;

boolean fill_toggle;
int fill_toggle_x = v_output_x + 100;
int fill_toggle_y = 20;
int fill_toggle_size = 20;

PImage h_img;
PImage v_img;
PImage hv_img;
PImage key_img;

int key_output_x = v_output_x + 50;
int key_output_y = h_output_y - 50;

int key_threshold;
int key_slider_x = key_output_x + the_size + 20;
int key_slider_width = 60;
int key_slider_y = key_output_y;
int key_slider_height = the_size;

PFont myFont;

// NOTE: keys 1-0 do things to the h ramp
// NOTE: keys q-p do things to the v ramp
// NOTE: The green bar is a slider to adjust the key that's next it.


//TODO: Make keys/buttons for operating on the ramps:
// rotate
// smooth
// shuffle
// quantize/bitcrush
// compressor/limiter (something to softly square sine waves?)
// reverse certain random parts
// wavefolder (amplify and fold the top and bottom spillover back in on itself)

//TODO: Fix the slider bugs
//      - the slider indicator sometimes isn't erased at the bottom

//TODO: Make it possible to set x and y of the ramps separately!
//      - no more single the_size, instead use size_x and size_y
//      - give it a default like a 4:3 screen?
//      - first step towards making the ramp profile boxes different size than screens!

void setup() {
  //frameRate(30);
  size(900, 900);
  background(51);

  myFont = createFont("SansSerif", 10);
  textFont(myFont);

  set_defaults(); // call this before setup_initial_ui()

  setup_initial_ui(); // a mess of drawing calls

}


void draw() {
  stroke(255);

  // if drawing in the H ramp box:
  if ((mousePressed == true) && (mouse_over_h())) {
    int new_mouse_x = constrain(mouseX, h_input_x, h_input_x + the_size-1);
    int old_mouse_x = constrain(pmouseX, h_input_x, h_input_x + the_size-1);
    int new_mouse_y = constrain(mouseY, h_input_y, h_input_x + the_size-1);
    int old_mouse_y = constrain(pmouseY, h_input_y, h_input_x + the_size-1);

    if(abs(new_mouse_x-old_mouse_x)>1){
      if(new_mouse_x>old_mouse_x){
        int dist_x = new_mouse_x - old_mouse_x;
        for (int x = 0; x < dist_x; x++) {
          float y = lerp(old_mouse_y, new_mouse_y, x/float(dist_x));
          //point(old_mouse_x+x+400, int(y));
          h_data[old_mouse_x + x - h_input_x] = the_size - (int(y) - h_input_y);
        }
      } else {
        int dist_x = old_mouse_x - new_mouse_x;
        for (int x = 0; x < dist_x; x++) {
          float y = lerp(new_mouse_y, old_mouse_y, x/float(dist_x));
          //point(new_mouse_x+x+400, int(y));
          h_data[new_mouse_x + x - h_input_x] = the_size - (int(y) - h_input_y);
        }
      }
    } else {
      h_data[new_mouse_x - h_input_x] = the_size - (new_mouse_y - h_input_y);
    }
    
    // All of the above in this if(mousepressed){} clause is in order to make smoother
    // mouse action. Otherwise it could all be replaced with the following line:
    //h_data[mouseX-h_input_x] = the_size-(mouseY-h_input_y);
    
    refresh_h_img();
    refresh_hv_img();
    refresh_key_img();
  }

  // if drawing in the V ramp box:
  if ((mousePressed == true) && (mouse_over_v())) {
    int new_mouse_x = constrain(mouseX, v_input_x, v_input_x + the_size-1);
    int old_mouse_x = constrain(pmouseX, v_input_x, v_input_x + the_size-1);
    int new_mouse_y = constrain(mouseY, v_input_y, v_input_x + the_size-1);
    int old_mouse_y = constrain(pmouseY, v_input_y, v_input_x + the_size-1);
    
    if(abs(new_mouse_y-old_mouse_y)>1){
      if(new_mouse_y>old_mouse_y){
        int dist_y = new_mouse_y - old_mouse_y;
        for (int y = 0; y < dist_y; y++) {
          float x = lerp(old_mouse_x, new_mouse_x, y/float(dist_y));
          v_data[old_mouse_y + y - v_input_y] = int(x) - v_input_x;
        }
      } else {
        int dist_y = old_mouse_y - new_mouse_y;
        for (int y = 0; y < dist_y; y++) {
          float x = lerp(new_mouse_x, old_mouse_x, y/float(dist_y));
          v_data[new_mouse_y + y - v_input_y] = int(x) - v_input_x;
        }
      }
    } else {
      v_data[new_mouse_y - v_input_y] = new_mouse_x - v_input_x;
    }
    
    // All of the above in this if(mousepressed){} clause is in order to make smoother
    // mouse action. Otherwise it could all be replaced with the following line:
    //v_data[mouseY-v_input_y] = (mouseX-v_input_x);

    refresh_v_img();
    refresh_hv_img();
    refresh_key_img();
  }
  
  // if clicking on the key slider:
  if ((mousePressed == true) && (mouse_over_key_slider())) {
    key_threshold = key_slider_y + key_slider_height - mouseY - 1;
    redraw_key_slider();
    refresh_key_img();
  }
  
  // (Checking for fill toggle click is in the mousePressed() function.)
  
  // clear the h input area
  noStroke();
  fill(0); // solid black
  rect(h_input_x, h_input_y, the_size, the_size);
  // redraw the h input area
  stroke(255);
  strokeWeight(1);
  for (int i = 0; i < (the_size - 1); i++) {
    int y = h_data[i];
    int last_y;
    if(i==0){
      last_y = h_data[i];
    } else {
      last_y = h_data[i-1];
    }
    if(fill_toggle) {
      line(h_input_x + i, h_input_y + the_size, h_input_x + i, h_input_y + the_size - y);
    } else {
      //point(h_input_x+i, h_input_y+the_size-h_data[i]);
      // Use the following line method to get rid of discontinuities of point method
      if(i != 0){
        line(h_input_x+i-1, h_input_y+the_size-last_y, h_input_x+i, h_input_y+the_size-y);
      }
    }
  }
  
  // draw the h output
  image(h_img, h_output_x, h_output_y);
  
  // clear the v input area
  noStroke();
  fill(0); // solid black
  rect(v_input_x, v_input_y, the_size, the_size);
  // redraw the v input area
  stroke(255);
  strokeWeight(1);
  for (int i = 0; i < (the_size - 1); i++) {
    int x = v_data[i];
    int last_x;
    if(i==0){
      last_x = v_data[i];
    } else {
      last_x = v_data[i-1];
    }
    if(fill_toggle) {
      line(v_input_x, v_input_y + i, v_input_x + x, v_input_y + i);
    } else {
      //point(v_input_x + v_data[i], v_input_y + i);
      // Use the following line method to get rid of discontinuities of point method
      if(i != 0){
        line(v_input_x + last_x, v_input_y + i, v_input_x + x, v_input_y + i);
      }
    }
  }

  // draw the v output
  image(v_img, v_output_x, v_output_y);

  // draw the h+v output
  image(hv_img, hv_output_x, hv_output_y);

  //refresh_key_img();

  // draw the key output
  image(key_img, key_output_x, key_output_y);

}

void set_defaults() {
  // make 2.5 sines that are nicely centered in amplitude
  fill_with_sines(h_data, 2.5);
  array_two_thirds_amp_and_offset(h_data);
  // make 4 ramps that are nicely centered in amplitude
  fill_with_linear_ramp(v_data);
  array_double_freq(v_data);
  array_double_freq(v_data);
  array_two_thirds_amp_and_offset(v_data);
  // default toggle off
  fill_toggle = false;
  redraw_fill_toggle();
  // default threshold is 50%
  key_threshold = int(the_size/2);
  redraw_key_slider();
}

// if clicking on the fill toggle:
void mousePressed() {
  // This is here instead of in draw() with the other mouse stuff in order to not have
  // the toggle oscillating if held for more than 1 draw cycle, which is very common.
  if (mouse_over_fill_toggle()) {
    fill_toggle = !fill_toggle;
    redraw_fill_toggle();
  }
}

boolean mouse_over_h() {
  int fudge = 5; // makes it easier to hit the extremes
  boolean result = ((mouseX >= h_input_x - fudge) && (mouseX < h_input_x + the_size + (2 * fudge)) && (mouseY >= h_input_y - fudge) && (mouseY < h_input_y + the_size + (2 * fudge)));
  return result;
}

boolean mouse_over_v() {
  int fudge = 5; // makes it easier to hit the extremes
  boolean result = ((mouseX >= v_input_x - fudge) && (mouseX < v_input_x + the_size + (2 * fudge)) && (mouseY >= v_input_y - fudge) && (mouseY < v_input_y + the_size + (2 * fudge)));
  return result;
}

boolean mouse_over_key_slider() {
  boolean result = ((mouseX >= key_slider_x)&&(mouseX < key_slider_x+key_slider_width)&&(mouseY >= key_slider_y-2)&&(mouseY < key_slider_y+key_slider_height+4));
  return result;
}

boolean mouse_over_fill_toggle() {
  boolean result = ((mouseX >= fill_toggle_x)&&(mouseX < fill_toggle_x+fill_toggle_size)&&(mouseY >= fill_toggle_y)&&(mouseY < fill_toggle_y+fill_toggle_size));
  return result;
}


void refresh_h_img() {
  h_img.loadPixels();
  for(int y = 0; y < the_size; y++) {
    for(int x = 0; x < the_size; x++) {
      h_img.pixels[x+(y*the_size)] = color(map(h_data[x],0,the_size,0,256)); 
    }
  }
  h_img.updatePixels();
}

void refresh_v_img() {
  v_img.loadPixels();
  for(int y = 0; y < the_size; y++) {
    for(int x = 0; x < the_size; x++) {
      v_img.pixels[x+(y*the_size)] = color(map(v_data[y],0,the_size,0,256));
    }
  }
  v_img.updatePixels();
}

void refresh_hv_img() {
  hv_img.loadPixels();
  h_img.loadPixels();
  v_img.loadPixels();
  for(int i = 0; i < hv_img.pixels.length; i++) {
    int mixed = int((brightness(h_img.pixels[i]) + brightness(v_img.pixels[i])) / 2);
    hv_img.pixels[i] = color(mixed); 
  }
  hv_img.updatePixels();
}

void refresh_key_img() {
  hv_img.loadPixels();
  key_img.loadPixels();
  for(int i = 0; i < hv_img.pixels.length; i++) {
    if ((brightness(hv_img.pixels[i]) * the_size / 255) > key_threshold) {
      key_img.pixels[i]  = color(255);
    }  else {
      key_img.pixels[i]  = color(0);
    }
  }
  key_img.updatePixels();
}

void redraw_key_slider() {
  noStroke();
  fill(0, 128, 0);
  //rect(key_slider_x, key_slider_y-2, key_slider_width, key_slider_height+4); // key slider
  rect(key_slider_x, key_slider_y-2-1, key_slider_width, key_slider_height+4+4+1); // key slider
  fill(255);
  rect(key_slider_x, key_slider_y+key_slider_height-key_threshold-1, key_slider_width, 3); // key slider
}

void redraw_fill_toggle() {
  stroke(200);
  strokeWeight(1);
  fill(0);
  rect(fill_toggle_x, fill_toggle_y, fill_toggle_size, fill_toggle_size);
  if(fill_toggle){
    stroke(200);
    strokeWeight(1);
    line(fill_toggle_x, fill_toggle_y, fill_toggle_x+fill_toggle_size, fill_toggle_y+fill_toggle_size);
    line(fill_toggle_x+fill_toggle_size, fill_toggle_y, fill_toggle_x, fill_toggle_y+fill_toggle_size);
  }
}

void keyPressed()
{
  switch(key) {
 
  // Functions that fill ramps with presets:
  // 1,2,3,4,5,6,7,8,9,0 for h ramp
  // q,w,e,r,t,y,u,i,o,p for v ramp

  case '1': 
    fill_with_linear_ramp(h_data);
    break;
  case 'q': 
    fill_with_linear_ramp(v_data);
    break;
    
  case '2': 
    fill_with_sine(h_data);
    break;
  case 'w': 
    fill_with_sine(v_data);
    break;
    
  case '3': 
    fill_with_lf_perlin(h_data);
    break;
  case 'e': 
    fill_with_lf_perlin(v_data);
    break;

  case '4': 
    fill_with_hf_perlin(h_data);
    break;
  case 'r': 
    fill_with_hf_perlin(v_data);
    break;
  
  case '5': 
    fill_with_rnd_walk(h_data);
    break;
  case 't': 
    fill_with_rnd_walk(v_data);
    break;
  
  case '6': 
    fill_with_rnd(h_data);
    break;
  case 'y': 
    fill_with_rnd(v_data);
    break;

  // ...

  case '9': 
    fill_with_white(h_data);
    break;
  case 'o': 
    fill_with_white(v_data);
    break;

  case '0': 
    fill_with_zero(h_data);
    break;
  case 'p': 
    fill_with_zero(v_data);
    break;

  // Functions that ADD ramps to the existing ramps:
  // !,@,#,$,%,^,&,*,(,)  to add to the h ramp
  // Q,W,E,R,T,Y,U,I,O,P  to add to the v ramp

  case '!': 
    avg_with_linear_ramp(h_data);
    break;
  case 'Q': 
    avg_with_linear_ramp(v_data);
    break;

  case '@': 
    avg_with_sine(h_data);
    break;
  case 'W': 
    avg_with_sine(v_data);
    break;
    
  case '#': 
    avg_with_lf_perlin(h_data);
    break;
  case 'E': 
    avg_with_lf_perlin(v_data);
    break;

  case '$': 
    avg_with_hf_perlin(h_data);
    break;
  case 'R': 
    avg_with_hf_perlin(v_data);
    break;
  
  case '%': 
    avg_with_rnd_walk(h_data);
    break;
  case 'T': 
    avg_with_rnd_walk(v_data);
    break;
  
  case '^': 
    avg_with_rnd(h_data);
    break;
  case 'Y': 
    avg_with_rnd(v_data);
    break;

  // ...

  case '(': 
    avg_with_white(h_data);
    break;
  case 'O': 
    avg_with_white(v_data);
    break;

  case ')': 
    avg_with_zero(h_data);
    break;
  case 'P': 
    avg_with_zero(v_data);
    break;
    
    

  // Functions that do stuff to existing ramps:
  // a,s,d,f,g,h,j for h ramp
  // z,x,c,v,b,n,m for v ramp

  case 'a': 
    array_invert(h_data);
    break;
  case 'z': 
    array_invert(v_data);
    break;

  case 'A': 
    array_reverse(h_data);
    break;
  case 'Z': 
    array_reverse(v_data);
    break;

  case 's': 
    array_double_freq(h_data);
    break;
  case 'x': 
    array_double_freq(v_data);
    break;

  case 'd': 
    array_half_and_mirror(h_data);
    break;
  case 'c': 
    array_half_and_mirror(v_data);
    break;
  
  case 'f': 
    add_a_little_noise(h_data);
    break;
  case 'v': 
    add_a_little_noise(v_data);
    break;

  case 'g': 
    array_maximize(h_data);
    break;
  case 'b': 
    array_maximize(v_data);
    break;
  
  // Misc functions:
  
  ////TODO: Make this work!
  //case '!': 
  //  set_it_all_totally_random();
  //  break;

  ////TODO: Make this work!
  //case '?': 
  //  show_help();
  //  break;
  
  case ' ': 
    set_defaults();
    break;
    
  case ';': 
    print("[");
    for (int i = 0; i < the_size; i++) {
      print(h_data[i]);
      print(" ");
    }
    println("]");
    break;
  case ':': 
    println(h_data);
    break;
  case '\'': 
    print("[");
    for (int i = 0; i < the_size; i++) {
      print(v_data[i]);
      print(" ");
    }
    println("]");
    break;
  case '"': 
    println(v_data);
    break;
  case '.': 
    println("h_data:");
    print("[");
    print(h_data[0]);
    print("\t");
    print(h_data[1]);
    print("\t...\t");
    print(h_data[the_size-2]);
    print("\t");
    print(h_data[the_size-1]);
    println("]");
    println("");
    break;  
  case '/': 
    println("v_data:");
    print("[");
    print(v_data[0]);
    print("\t");
    print(v_data[1]);
    print("\t...\t");
    print(v_data[the_size-2]);
    print("\t");
    print(v_data[the_size-1]);
    println("]");
    println("");
    break;  

}

  refresh_outputs();
}

void fill_with_linear_ramp(int[] the_array) {
  for (int i = 0; i < the_size; i++) {
    the_array[i] = i;
  }
}

void avg_with_linear_ramp(int[] the_array) {
  for (int i = 0; i < the_size; i++) {
    //the_array[i] = i;
    the_array[i] = int((the_array[i] + i)/2);
  }
}

void fill_with_zero(int[] the_array) {
  for (int i = 0; i < the_size; i++) {
    the_array[i] = 0;
  }
}

void avg_with_zero(int[] the_array) {
  for (int i = 0; i < the_size; i++) {
    //the_array[i] = 0;
    the_array[i] = int(the_array[i]/2);
  }
}

void fill_with_white(int[] the_array) {
  for (int i = 0; i < the_size; i++) {
    the_array[i] = 255;
  }
}

void avg_with_white(int[] the_array) {
  for (int i = 0; i < the_size; i++) {
    //the_array[i] = 255;
    the_array[i] = int((the_array[i] + 255)/2);
  }
}

void fill_with_rnd(int[] the_array) {
  for (int i = 0; i < the_size; i++) {
    the_array[i] = int(random(255));
  }
}

void avg_with_rnd(int[] the_array) {
  for (int i = 0; i < the_size; i++) {
    //the_array[i] = int(random(255));
    the_array[i] = int((the_array[i] + random(255))/2);
  }
}

void add_a_little_noise(int[] the_array) {
  for (int i = 0; i < the_size; i++) {
    the_array[i] = constrain(the_array[i] + int(random(8)-4), 0, 255);
  }
}

void fill_with_rnd_walk(int[] the_array) {
  int value = int(random(255));
  for (int i = 0; i < the_size; i++) {
    value = constrain(value + int(random(30)-15), 0, the_size);
    the_array[i] = value;
  }
}

void avg_with_rnd_walk(int[] the_array) {
  int value = int(random(255));
  for (int i = 0; i < the_size; i++) {
    value = constrain(value + int(random(30)-15), 0, the_size);
    //the_array[i] = value;
    the_array[i] = int((the_array[i] + value)/2);
  }
}

// only diff between fill_with_lf_perlin and fill_with_hf_perlin is step_size
void fill_with_lf_perlin(int[] the_array) {
  float offset = random(255);
  float step_size = 0.01;
  for (int i = 0; i < the_size; i++) {
    the_array[i] = int(noise((i * step_size) + offset) * the_size);
  }
}

void avg_with_lf_perlin(int[] the_array) {
  float offset = random(255);
  float step_size = 0.01;
  for (int i = 0; i < the_size; i++) {
    //the_array[i] = int(noise((i * step_size) + offset) * the_size);
    the_array[i] = int((the_array[i] + (noise((i * step_size) + offset) * the_size))/2);
  }
}

// only diff between fill_with_lf_perlin and fill_with_hf_perlin is step_size
void fill_with_hf_perlin(int[] the_array) {
  float offset = random(255);
  float step_size = 0.101;
  for (int i = 0; i < the_size; i++) {
    the_array[i] = int(noise((i * step_size) + offset) * the_size);
  }
}

void avg_with_hf_perlin(int[] the_array) {
  float offset = random(255);
  float step_size = 0.101;
  for (int i = 0; i < the_size; i++) {
    //the_array[i] = int(noise((i * step_size) + offset) * the_size);
    the_array[i] = int((the_array[i] + (noise((i * step_size) + offset) * the_size))/2);
  }
}

void fill_with_sine(int[] the_array) {
  for (int i = 0; i < the_size; i++) {
    the_array[i] = int((cos((i*TWO_PI/the_size)+PI)+1)*(the_size/2));
  }
}

void avg_with_sine(int[] the_array) {
  for (int i = 0; i < the_size; i++) {
    //the_array[i] = int((cos((i*TWO_PI/the_size)+PI)+1)*(the_size/2));
    the_array[i] = int((the_array[i] + ((cos((i*TWO_PI/the_size)+PI)+1)*(the_size/2)))/2);
  }
}

void fill_with_sines(int[] the_array, float cycles) {
  for (int i = 0; i < the_size; i++) {
    //the_array[i] = constrain(int((cos((cycles*i*TWO_PI/the_size)+PI)+1)*(the_size/2)),0,the_size);
    the_array[i] = int((cos((cycles*i*TWO_PI/the_size)+PI)+1)*(the_size/2));
  }
}

// not yet tested:
void avg_with_sines(int[] the_array, float cycles) {
  for (int i = 0; i < the_size; i++) {
    //the_array[i] = constrain(int((cos((cycles*i*TWO_PI/the_size)+PI)+1)*(the_size/2)),0,the_size);
    //the_array[i] = int((cos((cycles*i*TWO_PI/the_size)+PI)+1)*(the_size/2));
    the_array[i] = int((the_array[i] + ((cos((cycles*i*TWO_PI/the_size)+PI)+1)*(the_size/2)))/2);
  }
}

void array_half_amp_and_offset(int[] the_array) {
  for (int i = 0; i < the_size; i++) {
    the_array[i] = int((the_array[i]/2.0) + (the_size/4.0));
  }
}

void array_two_thirds_amp_and_offset(int[] the_array) {
  for (int i = 0; i < the_size; i++) {
    the_array[i] = int((the_array[i]*2.0/3.0) + (the_size/6.0));
  }
}

void array_double_freq(int[] the_array) {
  int[] temp_array = new int[the_size];
  int half_size = int(the_size/2);
  for (int i = 0; i < half_size; i++) {
    temp_array[i] = the_array[i*2];
  }
  for (int i = half_size; i < the_size - 1; i++) {
    temp_array[i] = temp_array[i-half_size];
  }
  for (int i = 0; i < (the_size - 1); i++) {
    the_array[i] = temp_array[i];
  }
}

void array_half_and_mirror(int[] the_array) {
  int[] temp_array = new int[the_size];
  int half_size = int(the_size/2);
  for (int i = 0; i < half_size; i++) {
    temp_array[i] = the_array[i*2];
  }
  for (int i = 0; i < half_size; i++) {
    temp_array[i+half_size] = temp_array[half_size-i-1];
  }
  arrayCopy(temp_array, the_array);
}

void array_invert(int[] the_array) {
  for (int i = 0; i < the_size; i++) {
    the_array[i] = the_size - 1 - the_array[i];
  }
}

void array_reverse(int[] the_array) {
  int[] temp_data = new int[the_size];
  for (int i = 0; i < the_size; i++) {
    temp_data[i] = the_array[the_size - i - 1];
  }
  arrayCopy(temp_data, the_array);
}

//// I was dumb when trying to reverse the whole array, so now it mirrors
//// the second half into the first half
//void array_mirror_second_half(int[] the_array) {
//  for (int i = 0; i < (the_size - 1); i++) {
//    the_array[i] = the_array[the_size - i - 1];
//  }
//}

// shuffle isn't very useful
void array_shuffle(int[] the_array) {
  int[] temp_data = new int[the_size];
  IntList new_order = new IntList();
  for (int i = 0; i < the_size; i++) {
    new_order.append(i);
  }
  new_order.shuffle();
  for (int i = 0; i < the_size; i++) {
    temp_data[i] = the_array[new_order.get(i)];
  }
  arrayCopy(temp_data, the_array);
}

void array_maximize(int[] the_array) {
  int the_min = min(the_array);
  int the_max = max(the_array);
  for (int i = 0; i < the_size; i++) {
    the_array[i] = int(map(the_array[i], the_min, the_max, 0, the_size));
  }
}


// rotate
// reverse
// inverse
// smooth



void refresh_outputs() {
  refresh_h_img();
  refresh_v_img();
  refresh_hv_img();
  refresh_key_img();
}


class Container {
  int x;
  int y;
  int width;
  int height;
  int value = 0;
  boolean enabled = true;
  // a few different ways you can construct a new instance
  Container() {
  }
  Container(int _x, int _y) {
    this.x = _x;
    this.y = _y;
  }
  Container(int _x, int _y, int _width, int _height) {
    this.x = _x;
    this.y = _y;
    this.width = _width;
    this.height = _height;
  }
}


// DRAW (and in some cases create) THE INITIAL UI ELEMENTS
// (moved to this function to keep the setup() function neater)
void setup_initial_ui() {
  
  // draw input areas:
  noFill();
  strokeWeight(2);
  stroke(255,0,0);
  rect(h_input_x, h_input_y, the_size, the_size); // h input outline
  stroke(0,0,255);
  rect(v_input_x, v_input_y, the_size, the_size); // v input outline

  noStroke();
  fill(0); // solid black
  rect(h_input_x, h_input_y, the_size, the_size); // h input
  rect(v_input_x, v_input_y, the_size, the_size); // v input

  fill(200);
  text("H RAMP PROFILE", h_input_x + 20, h_input_y - 5); // for h input
  text("V RAMP PROFILE", v_input_x + 20, v_input_y - 5); // for v input
  
  pushMatrix();
  translate(15, the_size);
  rotate(radians(-90));
  fill(200);
  text("INTENSITY ======>", 0, 0); // for h input
  popMatrix();

  fill(200);
  text("INTENSITY ======>", v_input_x + 20, v_input_y + the_size + 20); // for v input

  noFill();
  stroke(64,255,0);
  strokeWeight(2);
  rect(key_slider_x-1, key_slider_y-4, key_slider_width+2, key_slider_height+10); // key slider outline
  redraw_key_slider();

  fill(200);
  text("THRESHOLD", key_slider_x, key_slider_y - 8); // for key slider

  redraw_fill_toggle();
  fill(200);
  text("TOGGLE LINE/FILL STYLE FOR RAMP PROFILES", fill_toggle_x+fill_toggle_size+10, fill_toggle_y+fill_toggle_size-4); // for fill toggle

  // draw output areas:
  noFill();
  strokeWeight(8);
  stroke(255,0,0);
  rect(h_output_x, h_output_y, the_size, the_size); // h output outline
  stroke(0,0,255);
  rect(v_output_x, v_output_y, the_size, the_size); // v output outline
  stroke(255,0,255);
  rect(hv_output_x, hv_output_y, the_size, the_size); // h+v output outline
  stroke(0,255,0);
  rect(key_output_x, key_output_y, the_size, the_size); // key output outline
  
  noStroke();
  fill(0); // solid black
  rect(h_output_x, h_output_y, the_size, the_size); // h output
  rect(v_output_x, v_output_y, the_size, the_size); // v output
  rect(hv_output_x, hv_output_y, the_size, the_size); // h+v output

  h_img = createImage(the_size, the_size, RGB); // images for faster drawing
  refresh_h_img();
  v_img = createImage(h_img.width, h_img.height, RGB); // images for faster drawing
  refresh_v_img();
  hv_img = createImage(h_img.width, h_img.height, RGB); // images for faster drawing
  refresh_hv_img();
  key_img = createImage(h_img.width, h_img.height, RGB); // images for faster drawing
  refresh_key_img();
  
  // red arrow
  noFill();
  strokeWeight(3);
  stroke(255,0,0);
  int red_arrow_x = h_input_x + (the_size / 2);
  int red_arrow_back_y = h_output_y + the_size + 10;
  int red_arrow_front_y = hv_output_y - 10;
  line(red_arrow_x, red_arrow_back_y, red_arrow_x, red_arrow_front_y);
  line(red_arrow_x, red_arrow_front_y + 2, red_arrow_x - 10, red_arrow_front_y - 10);
  line(red_arrow_x, red_arrow_front_y + 2, red_arrow_x + 10, red_arrow_front_y - 10);
  // red arrow
  noFill();
  strokeWeight(3);
  stroke(0,0,255);
  int blue_arrow_front_x = hv_output_x + the_size + 10;
  int blue_arrow_back_x = v_output_x - 10;
  int blue_arrow_y = v_output_y + (the_size / 2);
  line(blue_arrow_front_x, blue_arrow_y, blue_arrow_back_x, blue_arrow_y);
  line(blue_arrow_front_x - 2, blue_arrow_y, blue_arrow_front_x + 10, blue_arrow_y - 10);
  line(blue_arrow_front_x - 2, blue_arrow_y, blue_arrow_front_x + 10, blue_arrow_y + 10);
  // purpple arrow
  noFill();
  strokeWeight(3);
  stroke(255,0,255);
  int purple_arrow_back_x = hv_output_x + the_size + 10;
  int purple_arrow_back_y = hv_output_y - 10;
  int purple_arrow_front_x = purple_arrow_back_x + 70;
  int purple_arrow_front_y = purple_arrow_back_y - 70;
  line(purple_arrow_front_x, purple_arrow_front_y, purple_arrow_back_x, purple_arrow_back_y);
  line(purple_arrow_front_x, purple_arrow_front_y, purple_arrow_front_x - 10, purple_arrow_front_y);
  line(purple_arrow_front_x, purple_arrow_front_y, purple_arrow_front_x, purple_arrow_front_y + 10);

}
