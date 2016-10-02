

class KeyFrame implements Comparable<KeyFrame> {
  int time;
  color col;
  boolean isSelected;
  int stagedMove;
  KeyframeBar kfBar;

  KeyFrame(int _time, color _col, KeyframeBar _kfBar) {
    time = _time;
    col = _col;
    isSelected = false;
    stagedMove = 0;
    kfBar = _kfBar;
  }
  
  KeyFrame(int _time) {
    time = _time;
    col = color(0,0,0);
    isSelected = false;
    stagedMove = 0;
  }
  
  boolean stageMove(int dt){
    int newTime = time + dt;
    stagedMove = dt;
    if(newTime<0 || newTime>audioBar.player.length()) return false;
    else return true;
  }
  
  void execMove(){
    time += stagedMove;
  }

  int getTime() {
    return time;
  }

  int compareTo(KeyFrame comparekey) {
    int compareage=((KeyFrame)comparekey).getTime();
    /* For Ascending order*/
    return this.time-compareage;

    /* For Descending order do like this */
    //return compareage-this.studentage;
  }
}