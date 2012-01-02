/*
 * This shows how to use a dynamic animation to draw into 
 * a projection-mapped shape.
 *
 */


void setupDynamicImages()
{
  // right now there is only the Whitney one

  DynamicGraphic whitneyDynamicImage = new DynamicGraphic(this, 256, 256); 
  whitneyDynamicImage.setup();
  


  // TODO: how about a registerDynamic( ) method that links a method to a specific PGraphics obj?

  /*
 // like this, but need a HashMap of <Method, PGraphics> to link them together
   java.lang.reflect.Method method;
   try {
   method = obj.getClass().getMethod(methodName, param1.class, param2.class, ..);
   } 
   catch (SecurityException e) {
   // ...
   } 
   catch (NoSuchMethodException e) {
   // ...
   }
   try {
   method.invoke(obj, arg1, arg2, ...);
   } 
   catch (IllegalArgumentException e) {
   } 
   catch (IllegalAccessException e) {
   } 
   catch (InvocationTargetException e) {
   */
}




// TODO: instead of PGraphics, make it a subclass with app.RegisterPreDraw() ? http://wiki.processing.org/w/Register_events
public class DynamicGraphic extends PGraphics3D
{
  // WhitneyScope - Jim Bumgardner
  // http://www.coverpop.com/p5/whitney_2/applet/whitney_2.pde
  // From ideas by John Whitney -- see his book "Digital Harmony"

  static final String NAME = "whitney";

  int   nbrPoints = 400;
  int   cx, cy;
  float crad;
  float cycleLength;
  float startTime;
  int   counter =0 ;
  float   speed = 1;
  boolean classicStyle = false;


  DynamicGraphic(PApplet app, int iwidth, int iheight)
  {
    super();
    setParent(app);
    setPrimary(false);
    //setAntiAlias(true);
    setSize(iwidth, iheight);

    // this attaches itself automagically to run the preDraw() method when the main
    // Processing app does

      app.registerPre(this);
    }


    void setup()
    {
      // add ourself to the glboal lists of dynamic images
      // Do we want to do this in the constructor or is that potentially evil?
      // Maybe we want to register copies with different params under different names...
      // Or potentially check for other entries in the HashMap and save to a different name
      sourceDynamic.put( NAME, this );
      sourceImages.put( NAME, this );
      
      
      nbrPoints = 400;
      counter =0 ;
      speed = 1;
      classicStyle = false;

      this.beginDraw();
      cx = this.width/2;
      cy = this.height/2;
      crad = (min(this.width, this.height)/2) * 0.95;
      this.noStroke();
      this.smooth();
      this.colorMode(HSB, 1);

      this.background(0);

      if (classicStyle)
        cycleLength = 15*60;
      else
        cycleLength = 2000*15*60;
      speed = (2*PI*nbrPoints) / cycleLength;
      startTime = -random(cycleLength);
      // speed = 10;
      this.endDraw();
    }


    //
    // do the actual drawing (off-screen)
    //
    void pre()
    {
      float my = 20;

      this.beginDraw();
      this.smooth();
      this.colorMode(HSB, 1);
      startTime = -(cycleLength*20) / (float) this.height;
      float timer = (millis()*.001 - startTime)*speed;

      this.background(0);
      counter = int(timer / cycleLength);

      for (int i = 0; i < nbrPoints; ++i)
      {

        float r = i/(float)nbrPoints;
        if ((counter & 1) == 0)
          r = 1-r;

        float a = timer * r; // pow(i * .001,2);
        // float a = timer*2*PI/(cycleLength/i); same thing
        float len = i*crad/(float)nbrPoints;
        float rad = max(2, len*.05);
        if (!classicStyle)
          len *= sin(a*timer);  // big fun!
        int x = (int) (cx + cos(a)*len);
        int y = (int) (cy + sin(a)*len);
        float h = r + timer * .01;
        h -= int(h);
        this.fill(h, .5, 1-r/2);
        this.ellipse(x, y, rad, rad);
      }
      this.endDraw();
    }
  }

