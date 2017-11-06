import java.awt.Polygon;
// an extended polygon class with my own customized createPolygon() method (feel free to improve!)

class PolygonBlob extends Polygon {



  // took me some time to make this method fully self-sufficient

  // now it works quite well in creating a correct polygon from a person's blob

  // of course many thanks to v3ga, because the library already does a lot of the work

  void createPolygon() {

    // an arrayList... of arrayLists... of PVectors

    // the arrayLists of PVectors are basically the person's contours (almost but not completely in a polygon-correct order)

    ArrayList<ArrayList<PVector>> contours = new ArrayList<ArrayList<PVector>>();

    // helpful variables to keep track of the selected contour and point (start/end point)

    // create contours from blobs

    // go over all the detected blobs

    for (int n=0 ; n<theBlobDetection.getBlobNb(); n++) {

        Blob b = theBlobDetection.getBlob(n);

      // for each substantial blob...

      if (b != null && b.getEdgeNb() > 100) {

        // create a new contour arrayList of PVectors

        ArrayList<PVector> contour = new ArrayList<PVector>();

        // go over all the edges in the blob

        for (int m=0; m<b.getEdgeNb(); m++) {

          // get the edgeVertices of the edge

          EdgeVertex eA = b.getEdgeVertexA(m);

          EdgeVertex eB = b.getEdgeVertexB(m);

          // if both ain't null...

          if (eA != null && eB != null) {

            // get next and previous edgeVertexA

            EdgeVertex fn = b.getEdgeVertexA((m+1) % b.getEdgeNb());

            EdgeVertex fp = b.getEdgeVertexA((max(0, m-1)));

            // calculate distance between vertexA and next and previous edgeVertexA respectively

            // positions are multiplied by kinect dimensions because the blob library returns normalized values

            float dn = dist(eA.x*kinectWidth, eA.y*kinectHeight, fn.x*kinectWidth, fn.y*kinectHeight);

            float dp = dist(eA.x*kinectWidth, eA.y*kinectHeight, fp.x*kinectWidth, fp.y*kinectHeight);

            // if either distance is bigger than 15 and the current contour size is bigger than zero

            if ((dn > 15 || dp > 15) && contour.size() > 0) {

                // add final point

                contour.add(new PVector(eB.x*kinectWidth, eB.y*kinectHeight));

                // add current contour to the arrayList

                contours.add(contour);

                // start a new contour arrayList

                contour = new ArrayList<PVector>();

            // if both distance are smaller than 15 (aka the points are close)  

            } else {

              // add the point to the list

              contour.add(new PVector(eA.x*kinectWidth, eA.y*kinectHeight));

            }

          }

        }

      }

    }

    

    // at this point in the code we have a list of contours (aka an arrayList of arrayLists of PVectors)

    // now we need to sort those contours into a correct polygon. To do this we need two things:

    // 1. The correct order of contours

    // 2. The correct direction of each contour

    int selectedContour = 0;

    boolean isLastPoint = false;

    // as long as there are contours left...    
    print(contours.size());
    while (contours.size() > 0) {

      // find next contour

      float distance = Float.MAX_VALUE;

      // if there are already points in the polygon
      
      if (npoints > 0) {

        // use the polygon's last point as a starting point

        PVector lastPoint = new PVector(xpoints[npoints-1], ypoints[npoints-1]);

        // go over all contours

        for (int i=0; i<contours.size(); i++) {

          ArrayList<PVector> c = contours.get(i);

          // get the contour's first point

          PVector fp = c.get(0);

          // get the contour's last point

          PVector lp = c.get(c.size()-1);

          // if the distance between the current contour's first point and the polygon's last point is smaller than distance

          if (fp.dist(lastPoint) < distance) {

            // set distance to this distance

            distance = fp.dist(lastPoint);

            // set this as the selected contour

            selectedContour = i;

            // set selectedPoint to 0 (which signals first point)

            isLastPoint = false;

          }

          // if the distance between the current contour's last point and the polygon's last point is smaller than distance

          if (lp.dist(lastPoint) < distance) {

            // set distance to this distance

            distance = lp.dist(lastPoint);

            // set this as the selected contour

            selectedContour = i;

            // set selectedPoint to 1 (which signals last point)

            isLastPoint = true;

          }

        }

      // if the polygon is still empty

      } else {

        // use a starting point in the lower-right

        PVector closestPoint = new PVector(width, height);

        // go over all contours

        for (int i=0; i<contours.size(); i++) {

          ArrayList<PVector> c = contours.get(i);

          // get the contour's first point

          PVector fp = c.get(0);

          // get the contour's last point

          PVector lp = c.get(c.size()-1);

          // if the first point is in the lowest 5 pixels of the (kinect) screen and more to the left than the current closestPoint

          if (fp.y > kinectHeight-5 && fp.x < closestPoint.x) {

            // set closestPoint to first point

            closestPoint = fp;

            // set this as the selected contour

            selectedContour = i;

            // set selectedPoint to 0 (which signals first point)

            isLastPoint = false;

          }

          // if the last point is in the lowest 5 pixels of the (kinect) screen and more to the left than the current closestPoint

          if (lp.y > kinectHeight-5 && lp.x < closestPoint.y) {

            // set closestPoint to last point

            closestPoint = lp;

            // set this as the selected contour

            selectedContour = i;

            // set selectedPoint to 1 (which signals last point)

            isLastPoint = true;

          }

        }

      }



      // add contour to polygon

      ArrayList<PVector> contour = contours.get(selectedContour);

      // if selectedPoint is bigger than zero (aka last point) then reverse the arrayList of points

      if (isLastPoint) 
        java.util.Collections.reverse(contour);

      // add all the points in the contour to the polygon

      for (PVector p : contour)
        addPoint(int(p.x), int(p.y));

      // remove this contour from the list of contours
      contours.remove(selectedContour);
   }
  }
}