
import java.nio.FloatBuffer;

//------------------------------------------------------------------
// This draws a "Whitney" image
//------------------------------------------------------------------

public class PsychedelicWhitney extends DynamicGraphic
{


  private GLModel glmodel;
  private GLTexture tex;

  // From ideas by John Whitney -- see his book "Digital Harmony"

  static final String NAME = "psychowhitney";
  final int MAX_POINTS = 500;

  float speed; // how fast it gains harmonics
  float periods; // how many humps the sine wave has
  float waveHeight;  // the height of the wave
  int hueOffset;
  int startTime;
  float speedRatio;
  int cycleLength;
  int numPoints;
  int blobSize;
  float fadeAmount;

  PVector pts[];

  PsychedelicWhitney(PApplet app, int iwidth, int iheight)
  {
    super( app, iwidth, iheight);

    // add ourself to the glboal lists of dynamic images
    // Do we want to do this in the constructor or is that potentially evil?
    // Maybe we want to register copies with different params under different names...
    // Or potentially check for other entries in the HashMap and save to a different name
    sourceDynamic.put( NAME, this );
    sourceImages.put( NAME, this );

    //app.registerDraw(this);
  }

  void initialize()
  {     
    waveHeight = this.height/6;
    startTime = millis();

    speed = 0.01; // how fast it gains harmonics
    periods = 1; // how many humps the sine wave has

    hueOffset = 56;

    speedRatio = 1.1;
    cycleLength = 60000;
    numPoints = 160;
    blobSize = 20;

    fadeAmount = 0.5;

    // initialize points array
    pts = new PVector[MAX_POINTS];

    for (int i=0; i<pts.length; i++)
      pts[i] = new PVector();

    tex = new GLTexture(this.app, "kittpart.png");

    initModel();

    println(this.NAME + "initialized");
  }


  //
  // do the actual drawing (off-screen)
  //
  void pre()
  {
    float s = sin(frameCount*speed);

    //float positiveSin = (1.0 + s) * 0.5; // from 0 - 1
    //  float varSpeed =  s*s * speed*speed + speed*speed;

    float varSpeed =  s * speed/speedRatio + speed;

    periods += varSpeed;

    this.beginDraw();

    this.fill(255);
    this.noStroke();
    this.stroke(255);


    GL gll = this.beginGL();
    gll.glClearColor(0f, 0f, 0f, 0f);
    gll.glClear(GL.GL_COLOR_BUFFER_BIT | GL.GL_DEPTH_BUFFER_BIT);
    gll.glDisable( GL.GL_DEPTH_TEST );
    gll.glEnable( GL.GL_BLEND );
    gll.glBlendFunc(GL.GL_SRC_ALPHA, GL.GL_ONE);

    //this.smooth();
    // this.colorMode(HSB, 1);

    strategy1();

    //this.glmodel.beginUpdateVertices();
    //this.glmodel.endUpdateVertices();

    //startTime = -(cycleLength*20) / (float) this.height;
    float timer = (millis() - startTime) % cycleLength;


    //for (PVector p : pts)
    //this.ellipse(p.x, p.y, blobSize, blobSize);
    this.setDepthMask(false);
    //    this.model(this.glmodel, 0, numPoints); 

    strategy2();

    this.setDepthMask(true);

    //this.glmodel.render(0,numPoints);  

    this.endGL();

    // strategy2();

    this.endDraw();
  }



  void strategy1()
  {
    if (this.glmodel != null)
    {
      this.glmodel.beginUpdateVertices();

      for (int index = 0; index < numPoints; index++)
      {
        float majorAngle = map(index, 0, numPoints, 0, TWO_PI);

        float angle = map(index, 0, numPoints, -periods*TWO_PI, periods*TWO_PI);

        float heightValue = waveHeight+waveHeight * 
          sin(majorAngle);

        float widthValue = waveHeight+waveHeight * 
          cos(majorAngle);

        float x = widthValue + (sin(angle)+1)*0.5*waveHeight;
        float y = heightValue + (cos(angle)+1)*0.5*60;

        PVector v = pts[index];

        x = lerp(v.x, x, fadeAmount);
        y = lerp(v.y, y, fadeAmount);

        v.set( x, y, 0);

        this.glmodel.updateVertex(index, v.x, v.y, v.z);
      }

      this.glmodel.endUpdateVertices();
    }
    else
      println("FAIL!");
  }


  void strategy2()
  {
    // draw another few rotated 90 degrees or so
    if (true)
    {
      pushMatrix();
      translate(width/2, height/2);
      rotate(HALF_PI);

      //translate(waveHeight/2, waveHeight/2);
      this.model(this.glmodel, 0, numPoints-1); 

      rotate(HALF_PI);
      this.model(this.glmodel, 0, numPoints-1);

      rotate(HALF_PI);
      this.model(this.glmodel, 0, numPoints-1);

      rotate(HALF_PI);
      this.model(this.glmodel, 0, numPoints-1);
      popMatrix();
    }
  }


  void setTexture(GLTexture _tex)
  {
    tex = _tex;
    if (this.glmodel != null) this.glmodel.setTexture(0, tex);
  }




  void updateModelColors(float r, float g, float b, float a)
  {     
    this.glmodel.beginUpdateColors();

    FloatBuffer cbuf = this.glmodel.colors;

    float col[] = { 
      0.9, 0.0, 0.0, 0.8
    };

    for (int n = 0; n < this.glmodel.getSize(); ++n) {

      // get colors (debugging purposes)
      //cbuf.position(4 * n);
      //cbuf.get(col, 0, 4);  
      //println("Color["+n+"]="+ col[0] +","+col[1] +","+col[2] +","+col[3]);
      // process col... make opaque white for testing
      //col[0] = col[1] = col[2] = col[3] = 1.0f;

      cbuf.position(4 * n);
      cbuf.put(col, 0, 4);
    }

    cbuf.rewind();
    this.glmodel.endUpdateColors();
  }  




  // 
  // Create the model initially
  //

  void initModel()
  {
    // make a geometry model with max size (we will only draw part of it as needed
    this.glmodel = new GLModel(this.app, MAX_POINTS, this.glmodel.POINT_SPRITES, GLModel.STREAM);

    println("MODEL CREATED? " + (this.glmodel != null));

    this.glmodel.beginUpdateVertices();
    int index = 0;

    for (PVector v : pts) 
    {
      this.glmodel.updateVertex(index, v.x, v.y, v.z);
      ++index;
    }
    this.glmodel.endUpdateVertices(); 

    //
    // Handle colors
    //

    this.glmodel.initColors();
    this.glmodel.beginUpdateColors();

    FloatBuffer cbuf = this.glmodel.colors;

    float col[] = { 
      1, 1, 1, 0.75
    };

    for (int n = 0; n < this.glmodel.getSize(); ++n) 
    {
      cbuf.position(4 * n);
      cbuf.put(col, 0, 4);
    }

    cbuf.rewind();
    this.glmodel.endUpdateColors();

    //float pmax = this.glmodel.getMaxSpriteSize();
    //println("Maximum sprite size supported by the video card: " + pmax + " pixels.");   

    this.glmodel.initTextures(1);
    this.glmodel.setTexture(0, tex);  

    // Setting the maximum sprite to the 90% of the maximum point size.
    //    model.setMaxSpriteSize(0.9 * pmax);
    // Setting the distance attenuation function so that the sprite size
    // is 20 when the distance to the camera is 400.

    this.glmodel.setSpriteSize(20, 600);
    this.glmodel.setBlendMode(BLEND);
  }

  // end class PsychoWhitney
}

