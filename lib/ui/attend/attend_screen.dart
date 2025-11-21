import 'dart:io';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:attendance_app/ui/attend/camera_screen.dart';
import 'package:attendance_app/ui/home_screen.dart';

class AttendScreen extends StatefulWidget {
  final XFile? image;

  const AttendScreen({super.key, this.image});

  @override
  State<AttendScreen> createState() => _AttendScreenState(image);
}

class _AttendScreenState extends State<AttendScreen> {
  _AttendScreenState(this.image);

  XFile? image;
  String strAlamat = "",
      strDate = "",
      strTime = "",
      strDateTime = "",
      strStatus = "Attend";
  bool isLoading = false;
  double dLat = 0.0, dLong = 0.0;
  int dateHours = 0, dateMinutes = 0;
  final controllerName = TextEditingController();
  final CollectionReference dataCollection = 
      FirebaseFirestore.instance.collection('attendance');

  @override
  void initState() {
    handleLocationPermission();
    setDateTime();
    setStatusAbsen();

    if (image != null) {
      isLoading = true;
      getGeoLocationPosition();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded, 
                     color: Colors.blue.shade600),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        centerTitle: true,
        title: Text(
          "Attendance Menu",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue.shade50,
                      Colors.blue.shade100,
                      Colors.blue.shade50,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.blue.shade200,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade500,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(Icons.camera_alt_rounded, 
                               color: Colors.white, 
                               size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Attendance Selfie",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Take a clear selfie photo for attendance",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Form Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Photo Capture Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Capture Photo",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            Text(
                              " *",
                              style: TextStyle(
                                color: Colors.red.shade500,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CameraScreen(),
                              ),
                            );
                          },
                          child: DottedBorder(
                            radius: const Radius.circular(16),
                            borderType: BorderType.RRect,
                            color: image != null ? Colors.green : Colors.blue,
                            strokeWidth: 2,
                            dashPattern: const [6, 4],
                            child: Container(
                              width: double.infinity,
                              height: 200,
                              decoration: BoxDecoration(
                                color: image != null 
                                    ? Colors.green.shade50 
                                    : Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: image != null
                                  ? Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(16),
                                          child: Image.file(
                                            File(image!.path),
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 12,
                                          right: 12,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade500,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.check_circle_rounded,
                                                    color: Colors.white, size: 16),
                                                const SizedBox(width: 4),
                                                Text(
                                                  "Photo Taken",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.camera_alt_outlined,
                                          color: Colors.blue.shade400,
                                          size: 52,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          "Tap to Take Photo",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.blue.shade600,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          "Please take a clear selfie photo",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Name Field
                    _buildFormField(
                      label: "Your Name",
                      hintText: "Enter your full name",
                      icon: Icons.person_outline_rounded,
                      controller: controllerName,
                      isRequired: true,
                    ),

                    const SizedBox(height: 20),

                    // Location Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Your Location",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            if (isLoading) ...[
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.blue.shade600),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(minHeight: 100),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: strAlamat.isNotEmpty 
                                  ? Colors.green.shade400 
                                  : Colors.grey.shade400,
                              width: 1.5,
                            ),
                            color: Colors.grey.shade50,
                          ),
                          padding: const EdgeInsets.all(16),
                          child: isLoading
                              ? Row(
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                            Colors.blue.shade600),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      "Getting your location...",
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.location_on_rounded,
                                      color: strAlamat.isNotEmpty 
                                          ? Colors.green.shade600 
                                          : Colors.blue.shade600,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            strAlamat.isEmpty
                                                ? "Location not available"
                                                : strAlamat,
                                            style: TextStyle(
                                              color: strAlamat.isEmpty
                                                  ? Colors.grey.shade500
                                                  : Colors.grey.shade700,
                                              fontSize: 14,
                                              height: 1.4,
                                            ),
                                          ),
                                          if (strAlamat.isNotEmpty) ...[
                                            const SizedBox(height: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.green.shade50,
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(
                                                  color: Colors.green.shade200,
                                                ),
                                              ),
                                              child: Text(
                                                "Location captured",
                                                style: TextStyle(
                                                  color: Colors.green.shade700,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Status & Time Info
                    Row(
                      children: [
                        // Status Card
                        Expanded(
                          child: _buildInfoCard(
                            title: "Status",
                            value: strStatus,
                            valueColor: _getStatusColor(),
                            icon: Icons.fact_check_rounded,
                            backgroundColor: _getStatusColor().withOpacity(0.1),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Time Card
                        Expanded(
                          child: _buildInfoCard(
                            title: "Current Time",
                            value: strTime.isNotEmpty ? strTime : "--:--:--",
                            valueColor: Colors.blue.shade700,
                            icon: Icons.access_time_rounded,
                            backgroundColor: Colors.blue.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Date Card
                    _buildInfoCard(
                      title: "Date",
                      value: strDate.isNotEmpty ? strDate : "-- -- --",
                      valueColor: Colors.purple.shade700,
                      icon: Icons.calendar_today_rounded,
                      backgroundColor: Colors.purple.withOpacity(0.1),
                      isFullWidth: true,
                    ),

                    const SizedBox(height: 32),

                    // Submit Button
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.blue.shade600,
                            Colors.blue.shade500,
                            Colors.blue.shade400,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            if (image == null || controllerName.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline_rounded,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          "Please take a photo and enter your name!",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: Colors.orange.shade600,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                  padding: const EdgeInsets.all(16),
                                ),
                              );
                            } else {
                              submitAbsen(
                                strAlamat,
                                controllerName.text.toString(),
                                strStatus,
                              );
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.send_rounded, 
                                   color: Colors.white, 
                                   size: 20),
                              const SizedBox(width: 12),
                              Text(
                                "Submit Attendance",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required String hintText,
    required IconData icon,
    required TextEditingController controller,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            if (isRequired)
              Text(
                " *",
                style: TextStyle(
                  color: Colors.red.shade500,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          textInputAction: TextInputAction.done,
          keyboardType: TextInputType.text,
          controller: controller,
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 14,
          ),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: Colors.blue.shade500, width: 2),
            ),
            prefixIcon: Icon(
              icon,
              color: Colors.grey.shade600,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required Color valueColor,
    required IconData icon,
    required Color backgroundColor,
    bool isFullWidth = false,
  }) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: valueColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: valueColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: valueColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (strStatus) {
      case "Attend":
        return Colors.green.shade600;
      case "Late":
        return Colors.orange.shade600;
      case "Leave":
        return Colors.red.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  // Get realtime location
  Future<void> getGeoLocationPosition() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
    setState(() {
      isLoading = false;
      getAddressFromLongLat(position);
    });
  }

  // Get address by lat long
  Future<void> getAddressFromLongLat(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          dLat = position.latitude;
          dLong = position.longitude;
          strAlamat =
              "${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}";
        });
      }
    } catch (e) {
      setState(() {
        strAlamat = "Unable to get address: $e";
      });
    }
  }

  // Permission location
  Future<bool> handleLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.location_off_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Location services are disabled. Please enable the services.",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.blue.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.all(16),
        ),
      );
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.location_off_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  "Location permission denied.",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            backgroundColor: Colors.blue.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.all(16),
          ),
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.location_off_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Location permission denied forever, we cannot access.",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.blue.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.all(16),
        ),
      );
      return false;
    }
    return true;
  }

  // Show progress dialog
  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      content: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Submitting Attendance...",
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Please wait a moment",
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  // Check format date time
  void setDateTime() async {
    var dateNow = DateTime.now();
    var dateFormat = DateFormat('dd MMMM yyyy');
    var dateTime = DateFormat('HH:mm:ss');
    var dateHour = DateFormat('HH');
    var dateMinute = DateFormat('mm');

    setState(() {
      strDate = dateFormat.format(dateNow);
      strTime = dateTime.format(dateNow);
      strDateTime = "$strDate | $strTime";

      dateHours = int.parse(dateHour.format(dateNow));
      dateMinutes = int.parse(dateMinute.format(dateNow));
    });
  }

  // Check status absent
  void setStatusAbsen() {
    if (dateHours < 8 || (dateHours == 8 && dateMinutes <= 30)) {
      strStatus = "Attend";
    } else if ((dateHours > 8 && dateHours < 18) ||
        (dateHours == 8 && dateMinutes >= 31)) {
      strStatus = "Late";
    } else {
      strStatus = "Leave";
    }
  }

  // Submit data absent to firebase
  Future<void> submitAbsen(String alamat, String nama, String status) async {
    showLoaderDialog(context);
    
    try {
      await dataCollection.add({
        'address': alamat,
        'name': nama,
        'description': status,
        'datetime': strDateTime,
        'created_at': FieldValue.serverTimestamp(),
      });

      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Yeay! Attendance Submitted Successfully!",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (error) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Error: $error",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.all(16),
        ),
      );
    }
  }
}