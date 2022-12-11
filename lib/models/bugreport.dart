class BugReport {
  final String bugReportId;
  final String uid;
  final String name;
  final String content;
  final DateTime createdAt;
  final String downloadUrl;
  final String platformVersion;
  final String imeiNo;
  final String modelName;
  final String manufacturer;
  final int apiLevel;
  final String deviceName;
  final String productName;
  final String cpuType;
  final String hardware;
  // Constructor
  BugReport({
    required this.bugReportId,
    required this.uid,
    required this.name,
    required this.content,
    required this.createdAt,
    required this.downloadUrl,
    required this.platformVersion,
    required this.imeiNo,
    required this.modelName,
    required this.manufacturer,
    required this.apiLevel,
    required this.deviceName,
    required this.productName,
    required this.cpuType,
    required this.hardware,
  });

  // ToJson
  Map<String, Object?> toJson() => {
        'bugReportId': bugReportId,
        'uid': uid,
        'name': name,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'downloadUrl': downloadUrl,
        'platformVersion': platformVersion,
        'imeiNo': imeiNo,
        'modelName': modelName,
        'manufacturer': manufacturer,
        'apiLevel': apiLevel,
        'deviceName': deviceName,
        'productName': productName,
        'cpuType': cpuType,
        'hardware': hardware,
      };

  // From Json
  static BugReport fromJson(Map<String, dynamic> json) => BugReport(
        bugReportId: json['bugReportId'] ?? '',
        uid: json['uid'] ?? '',
        name: json['name'] ?? '',
        content: json['content'] ?? '',
        downloadUrl: json['downloadUrl'] ?? '',
        platformVersion: json['platformVersion'] ?? '',
        imeiNo: json['imeiNo'] ?? '',
        modelName: json['modelName'] ?? '',
        manufacturer: json['manufacturer'] ?? '',
        apiLevel: json['apiLevel'] ?? 0,
        deviceName: json['deviceName'] ?? '',
        productName: json['productName'] ?? '',
        cpuType: json['cpuType'] ?? '',
        hardware: json['hardware'] ?? '',
        //
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
        //
      );
}
