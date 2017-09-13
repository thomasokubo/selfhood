// Java file imports
import java.util.Iterator;
import java.util.Arrays;

class KRecord {

  ArrayList<String> record;
  boolean isLoaded;
  Iterator<String> recIterator;

  KRecord() {
    record = new ArrayList<String>();
    isLoaded = false;
  }

  void addFrameRecord(HashMap<Integer, PVector[]> bodies) {
    record.add(((Integer)bodies.size()).toString());
    for (Integer id : bodies.keySet()) {
      String frameRecord = id.toString();
      for (PVector p : bodies.get(id))
        frameRecord += ";" + p.x + "," + p.y +"," + p.z;
      record.add(frameRecord);
    }
  }

  void saveRecord(String fileName) {
    saveStrings("Data/" + fileName, record.toArray(new String[0]));
  }

  void loadRecord(String fileName) {
      String[] fileRecord = loadStrings(fileName);
      
      if (fileRecord == null) {
        println("File not loaded");
        exit();
        return;
      }
      
      record = new ArrayList<String> (Arrays.asList(fileRecord));
      isLoaded = true;
      recIterator = record.iterator();
  }

  boolean hasFrame() {
    return recIterator.hasNext();
  }

  HashMap<Integer, PVector[]> getFrame() {
    if (!isLoaded || !hasFrame())
      return null;

    HashMap<Integer, PVector[]> bodies = new HashMap<Integer, PVector[]>();

    if (recIterator.hasNext()) {
      for (int i = Integer.valueOf(recIterator.next()); i > 0; i--) {
        String[] frameRec = recIterator.next().split(";");

        int id = Integer.valueOf(frameRec[0]);
        PVector[] joints = new PVector[frameRec.length - 1];

        for (int b = 1; b < frameRec.length; b++) {
          String[] vectorValue = frameRec[b].split(",");
          joints[b - 1] = new PVector(Float.valueOf(vectorValue[0]), Float.valueOf(vectorValue[1]), Float.valueOf(vectorValue[2]));
        }
        bodies.put(id, joints);
      }
    }

    return bodies;
  }
}
