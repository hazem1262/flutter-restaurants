class ApiConfigs{
  static String schema = "http";
  static String host = "10.0.1.78";

}

class ApiEndPoints {
  static String loginEndPoint = "/ChurchMemberShipAPI/BaptismServices.svc/Login";
  static String searchEndPoint = "/ChurchMemberShipAPI/Marriage.svc/12345/quickSearch";
  static String searchDetailsEndPoint = "/ChurchMemberShipAPI/Marriage.svc/12345/GetMemberInfo";
  static String searchFamilyMembers = "/ChurchMemberShipAPI/Confession.svc/12345/GetFamilies";

}

class ApiHeaders {
  static String contentType = "Content-Type";
  static String contentTypeValue = "application/json";

}