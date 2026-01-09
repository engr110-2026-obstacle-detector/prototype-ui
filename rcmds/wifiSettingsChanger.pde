TypeBox portWifiSettingsTypeBox;
TypeBox ipWifiSettingsTypeBox;
Button redSaveWifiButton;
Button redRecallWifiButton;
Button blueSaveWifiButton;
Button blueRecallWifiButton;
Button loadWifiHotspotSettingsButton;
void setupWifiSettingsChanger(float x, float y) {
  ipWifiSettingsTypeBox=new TypeBox(x, height/40+y, width/4, height/20, "ip: ", color(0, 255, 0));
  portWifiSettingsTypeBox=new TypeBox(x, 3*height/40+1+y, width/4, height/20, "port: ", color(0, 255, 0));
  loadWifiHotspotSettingsButton=new Button(x, y+height/6, height/8, color(70, 5, 70), color(200), null, 0, true, false, "hotspot");
}
void runWifiSettingsChanger() {
  wifiIP=ipWifiSettingsTypeBox.run(wifiIP);
  wifiPort=portWifiSettingsTypeBox.run(wifiPort);
  loadWifiHotspotSettingsButton.run();
  if (loadWifiHotspotSettingsButton.justPressed()) {
    wifiPort=25210;
    wifiIP="192.168.4.1";
  }
}
