import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:isuze_pqcs/common/constants.dart';

class HelpPage extends StatefulWidget {
  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String selectedCategory = 'overview';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 768;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: mycolor,
        title: Text(
          'Help & User Guide',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                mycolor,
                mycolor.withOpacity(0.8),
              ],
            ),
          ),
        ),
        actions: [
          if (!isTablet)
            PopupMenuButton<String>(
              icon: Icon(FeatherIcons.menu, color: Colors.white),
              onSelected: (value) {
                setState(() {
                  selectedCategory = value;
                });
              },
              itemBuilder: (context) => [
                _buildPopupMenuItem(
                    'overview', 'System Overview', FeatherIcons.info),
                _buildPopupMenuItem(
                    'dashboard', 'Dashboard Guide', FeatherIcons.home),
                _buildPopupMenuItem(
                    'operations', 'Operations', FeatherIcons.truck),
                _buildPopupMenuItem(
                    'quality', 'Quality Control', FeatherIcons.checkCircle),
                _buildPopupMenuItem(
                    'claims', 'Claims & Defects', FeatherIcons.xCircle),
                _buildPopupMenuItem(
                    'safety', 'Safety Reports', FeatherIcons.shield),
                _buildPopupMenuItem(
                    'profile', 'Profile Management', FeatherIcons.user),
                _buildPopupMenuItem('troubleshooting', 'Troubleshooting',
                    FeatherIcons.settings),
              ],
            ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: isTablet ? _buildTabletLayout() : _buildMobileLayout(),
          );
        },
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      children: [
        // Sidebar Navigation
        Container(
          width: 280,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(2, 0),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      mycolor.withOpacity(0.2),
                      mycolor.withOpacity(0.1)
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: mycolor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        FeatherIcons.helpCircle,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Help Categories',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: mycolor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(12),
                  children: [
                    _buildCategoryItem(
                        'overview', 'System Overview', FeatherIcons.info),
                    _buildCategoryItem(
                        'dashboard', 'Dashboard Guide', FeatherIcons.home),
                    _buildCategoryItem(
                        'operations', 'Operations', FeatherIcons.truck),
                    _buildCategoryItem(
                        'quality', 'Quality Control', FeatherIcons.checkCircle),
                    _buildCategoryItem(
                        'claims', 'Claims & Defects', FeatherIcons.xCircle),
                    _buildCategoryItem(
                        'safety', 'Safety Reports', FeatherIcons.shield),
                    _buildCategoryItem(
                        'profile', 'Profile Management', FeatherIcons.user),
                    _buildCategoryItem('troubleshooting', 'Troubleshooting',
                        FeatherIcons.settings),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Content Area
        Expanded(
          child: Container(
            padding: EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: _buildContent(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        // Category Selector for Mobile
        Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: mycolor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getCategoryIcon(selectedCategory),
                  color: Colors.white,
                  size: 18,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  _getCategoryTitle(selectedCategory),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: mycolor,
                  ),
                ),
              ),
              Icon(
                FeatherIcons.chevronDown,
                color: mycolor,
                size: 20,
              ),
            ],
          ),
        ),
        // Content Area
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              child: _buildContent(),
            ),
          ),
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(
      String value, String title, IconData icon) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: selectedCategory == value ? mycolor : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              size: 16,
              color: selectedCategory == value
                  ? Colors.white
                  : Colors.grey.shade600,
            ),
          ),
          SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: selectedCategory == value
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'overview':
        return FeatherIcons.info;
      case 'dashboard':
        return FeatherIcons.home;
      case 'operations':
        return FeatherIcons.truck;
      case 'quality':
        return FeatherIcons.checkCircle;
      case 'claims':
        return FeatherIcons.xCircle;
      case 'safety':
        return FeatherIcons.shield;
      case 'profile':
        return FeatherIcons.user;
      case 'troubleshooting':
        return FeatherIcons.settings;
      default:
        return FeatherIcons.info;
    }
  }

  String _getCategoryTitle(String category) {
    switch (category) {
      case 'overview':
        return 'System Overview';
      case 'dashboard':
        return 'Dashboard Guide';
      case 'operations':
        return 'Operations';
      case 'quality':
        return 'Quality Control';
      case 'claims':
        return 'Claims & Defects';
      case 'safety':
        return 'Safety Reports';
      case 'profile':
        return 'Profile Management';
      case 'troubleshooting':
        return 'Troubleshooting';
      default:
        return 'System Overview';
    }
  }

  Widget _buildCategoryItem(String category, String title, IconData icon) {
    bool isSelected = selectedCategory == category;
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? mycolor.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: isSelected ? Border.all(color: mycolor.withOpacity(0.5)) : null,
      ),
      child: ListTile(
        dense: true,
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected ? mycolor : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : Colors.grey.shade600,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? mycolor : Colors.grey.shade800,
            fontSize: 14,
          ),
        ),
        onTap: () {
          setState(() {
            selectedCategory = category;
          });
        },
      ),
    );
  }

  Widget _buildContent() {
    switch (selectedCategory) {
      case 'overview':
        return _buildOverviewContent();
      case 'dashboard':
        return _buildDashboardContent();
      case 'operations':
        return _buildOperationsContent();
      case 'quality':
        return _buildQualityContent();
      case 'claims':
        return _buildClaimsContent();
      case 'safety':
        return _buildSafetyContent();
      case 'profile':
        return _buildProfileContent();
      case 'troubleshooting':
        return _buildTroubleshootingContent();
      default:
        return _buildOverviewContent();
    }
  }

  Widget _buildOverviewContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('InfoPlus PQCS System Overview', FeatherIcons.info),
        _buildInfoCard(
          'What is InfoPlus PQCS?',
          'InfoPlus Production Quality Control System (PQCS) is a comprehensive manufacturing quality management platform designed for automotive production lines. It helps track, monitor, and ensure quality standards throughout the production process.',
          Colors.blue,
        ),
        SizedBox(height: 16),
        _buildInfoCard(
          'Key Features',
          '• Real-time quality monitoring\n• Production planning and scheduling\n• Vehicle receiving and inspection\n• Assembly station management\n• Defect tracking and claims processing\n• Safety incident reporting\n• Comprehensive reporting and analytics',
          Colors.green,
        ),
        SizedBox(height: 16),
        _buildInfoCard(
          'System Architecture',
          'The system is organized into several main modules:\n\n1. Operations: Vehicle receiving, planning, assembly\n2. Quality Control: QFL 3/TMS, QFL 4, QFL 5/6, MPA\n3. Claims & Defects: Quality defects, claims management\n4. Safety: Near miss reports, 5S audits\n5. Account Management: Profile and system settings',
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildDashboardContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Dashboard Guide', FeatherIcons.home),
        _buildStepCard(1, 'Main Dashboard',
            'The dashboard provides an overview of all system activities with real-time data and quick action buttons.'),
        _buildStepCard(2, 'Navigation Menu',
            'Use the drawer menu (☰) to access different modules. Menu items are organized by categories.'),
        _buildStepCard(3, 'Quick Actions',
            'The floating action button provides quick access to frequently used features like Vehicle Receiving, Planning, QFL 3/TMS, and Profile.'),
        _buildStepCard(4, 'System Status',
            'The welcome card shows system status and connection information.'),
        _buildInfoCard(
          'Navigation Tips',
          '• Use the search functionality to quickly find specific vehicles or records\n• The dashboard auto-refreshes to show latest data\n• Quick actions are context-sensitive based on your role\n• All navigation maintains your current session',
          mycolor,
        ),
      ],
    );
  }

  Widget _buildOperationsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Operations Module', FeatherIcons.truck),
        _buildSubSection('Vehicle Receiving', FeatherIcons.truck),
        _buildStepCard(1, 'Access Module',
            'Navigate to Operations > Vehicle Receiving from the menu or use Quick Actions.'),
        _buildStepCard(2, 'Vehicle Registration',
            'Register incoming vehicles with VIN, model, and customer information.'),
        _buildStepCard(3, 'Initial Inspection',
            'Perform initial quality checks and document any pre-existing conditions.'),
        _buildStepCard(4, 'Status Tracking',
            'Track vehicle progress through different production stages.'),
        SizedBox(height: 20),
        _buildSubSection('Planning', FeatherIcons.calendar),
        _buildStepCard(1, 'Production Scheduling',
            'Create and manage production schedules for different assembly lines.'),
        _buildStepCard(2, 'Resource Allocation',
            'Assign vehicles to specific stations and time slots.'),
        _buildStepCard(3, 'Timeline Management',
            'Monitor production timelines and adjust schedules as needed.'),
        SizedBox(height: 20),
        _buildSubSection('Assembly Stations', FeatherIcons.settings),
        _buildStepCard(1, 'Station Management',
            'Monitor and manage different assembly stations in real-time.'),
        _buildStepCard(2, 'Work Orders',
            'Track work orders and completion status for each station.'),
        _buildStepCard(3, 'Quality Checkpoints',
            'Ensure quality standards at each assembly checkpoint.'),
      ],
    );
  }

  Widget _buildQualityContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Quality Control Module', FeatherIcons.checkCircle),
        _buildSubSection(
            'QFL 3/TMS (Torque Management System)', FeatherIcons.folder),
        _buildStepCard(1, 'Select Vehicle',
            'Choose the vehicle unit from the QFL 3 units list.'),
        _buildStepCard(2, 'Station Selection',
            'Select the appropriate station for torque measurements.'),
        _buildStepCard(3, 'Operation Selection',
            'Choose the specific operation/joint for torque entry.'),
        _buildStepCard(4, 'Torque Entry',
            'Enter torque values in Nm. Previous entries are shown for reference.'),
        _buildStepCard(5, 'Validation',
            'System validates entries against specifications before submission.'),
        SizedBox(height: 20),
        _buildSubSection('QFL 4 Process', FeatherIcons.folderPlus),
        _buildStepCard(1, 'Process Documentation',
            'Document quality checks for QFL 4 specifications.'),
        _buildStepCard(2, 'Measurement Recording',
            'Record precise measurements and tolerances.'),
        _buildStepCard(3, 'Compliance Verification',
            'Verify compliance with QFL 4 standards.'),
        SizedBox(height: 20),
        _buildSubSection('QFL 5/6 & MPA', FeatherIcons.folderPlus),
        _buildStepCard(1, 'Advanced Quality Checks',
            'Perform comprehensive quality assessments.'),
        _buildStepCard(2, 'Multi-Point Analysis',
            'Conduct detailed MPA (Multi-Point Analysis) procedures.'),
        _buildStepCard(3, 'Final Verification',
            'Complete final quality verification before approval.'),
        _buildInfoCard(
          'Quality Control Best Practices',
          '• Always verify vehicle information before starting quality checks\n• Follow the prescribed sequence for measurements\n• Double-check entries before submission\n• Report any anomalies immediately\n• Maintain proper documentation for traceability',
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildClaimsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
            'Claims & Defects Management', FeatherIcons.xCircle),
        _buildSubSection('Quality Defects', FeatherIcons.xCircle),
        _buildStepCard(1, 'Defect Identification',
            'Identify and categorize quality defects found during inspection.'),
        _buildStepCard(2, 'Documentation',
            'Document defects with photos, descriptions, and severity levels.'),
        _buildStepCard(3, 'Assignment',
            'Assign defects to appropriate teams for resolution.'),
        _buildStepCard(
            4, 'Tracking', 'Track defect resolution progress and closure.'),
        SizedBox(height: 20),
        _buildSubSection('Claims Processing', FeatherIcons.messageSquare),
        _buildStepCard(1, 'Claim Initiation',
            'Create new claims with detailed information and supporting evidence.'),
        _buildStepCard(2, 'Review Process',
            'Submit claims for review by quality assurance teams.'),
        _buildStepCard(
            3, 'Investigation', 'Track investigation progress and findings.'),
        _buildStepCard(4, 'Resolution',
            'Monitor claim resolution and corrective actions.'),
        _buildInfoCard(
          'Defect Reporting Guidelines',
          '• Report defects immediately when discovered\n• Provide clear, detailed descriptions\n• Include relevant photos and measurements\n• Specify affected components and systems\n• Follow up on resolution status\n• Document lessons learned',
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildSafetyContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Safety Reporting Module', FeatherIcons.shield),
        _buildSubSection('Near Miss Reports', FeatherIcons.alertTriangle),
        _buildStepCard(1, 'Incident Identification',
            'Identify and report near miss incidents that could have resulted in injury or damage.'),
        _buildStepCard(2, 'Report Creation',
            'Create detailed reports with location, time, and circumstances.'),
        _buildStepCard(3, 'Root Cause Analysis',
            'Analyze potential causes and contributing factors.'),
        _buildStepCard(4, 'Preventive Actions',
            'Recommend and implement preventive measures.'),
        SizedBox(height: 20),
        _buildSubSection('5S Audit System', FeatherIcons.checkSquare),
        _buildStepCard(1, 'Audit Scheduling',
            'Schedule regular 5S audits for work areas and stations.'),
        _buildStepCard(2, 'Assessment',
            'Evaluate areas based on Sort, Set in Order, Shine, Standardize, and Sustain.'),
        _buildStepCard(3, 'Scoring',
            'Assign scores and identify improvement opportunities.'),
        _buildStepCard(4, 'Action Plans',
            'Create and track action plans for improvements.'),
        _buildInfoCard(
          'Safety Reporting Principles',
          '• Report all incidents, no matter how minor\n• Focus on facts, not blame\n• Include witnesses and evidence when possible\n• Follow up on corrective actions\n• Share learnings across teams\n• Maintain confidentiality when required',
          mycolor,
        ),
      ],
    );
  }

  Widget _buildProfileContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Profile Management', FeatherIcons.user),
        _buildStepCard(1, 'Accessing Profile',
            'Access your profile through the drawer menu (Account > My Profile) or Quick Actions.'),
        _buildStepCard(2, 'Profile Picture',
            'Tap the profile picture to upload or change your photo from gallery.'),
        _buildStepCard(3, 'View Information',
            'Review your name, email, and username information.'),
        _buildStepCard(4, 'Change Password',
            'Use the "Change Password" option to update your login credentials.'),
        _buildStepCard(5, 'Logout',
            'Use the "Logout" option to securely sign out of the system.'),
        SizedBox(height: 20),
        _buildSubSection('Password Security', FeatherIcons.lock),
        _buildInfoCard(
          'Password Requirements',
          '• Use a strong password with at least 8 characters\n• Include uppercase and lowercase letters\n• Add numbers and special characters\n• Avoid using personal information\n• Change password regularly\n• Never share your credentials',
          Colors.blue,
        ),
        SizedBox(height: 16),
        _buildInfoCard(
          'Account Security Tips',
          '• Always logout when using shared devices\n• Report any suspicious account activity\n• Keep your profile information updated\n• Use secure networks for system access\n• Enable notifications for account changes',
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildTroubleshootingContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Troubleshooting Guide', FeatherIcons.settings),
        _buildSubSection('Common Issues', FeatherIcons.alertCircle),
        _buildTroubleshootingItem(
          'Cannot Login',
          'Solutions:\n• Verify username and password\n• Check internet connection\n• Clear app cache\n• Contact system administrator',
        ),
        _buildTroubleshootingItem(
          'Data Not Loading',
          'Solutions:\n• Check network connectivity\n• Refresh the page\n• Logout and login again\n• Verify server status',
        ),
        _buildTroubleshootingItem(
          'Cannot Submit Forms',
          'Solutions:\n• Check all required fields\n• Verify data formats\n• Check file size limits\n• Try again after some time',
        ),
        _buildTroubleshootingItem(
          'App Crashes',
          'Solutions:\n• Update the app\n• Restart the device\n• Clear app data\n• Reinstall if necessary',
        ),
        SizedBox(height: 20),
        _buildSubSection('Getting Help', FeatherIcons.headphones),
        _buildInfoCard(
          'Support Contacts',
          'For technical support:\n• IT Help Desk: ext. 1234\n• Quality Team: ext. 5678\n• System Admin: admin@company.com\n• Emergency Support: ext. 9999\n\nFor training and user guidance:\n• Training Team: training@company.com\n• User Manual: Available in system documents',
          Colors.purple,
        ),
        SizedBox(height: 16),
        _buildInfoCard(
          'System Status',
          'Check system status and maintenance schedules:\n• System Status Page: status.company.com\n• Maintenance Windows: Sundays 2-4 AM\n• Version Updates: Monthly\n• Backup Schedule: Daily at midnight',
          Colors.blue,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    final isMobile = MediaQuery.of(context).size.width <= 768;

    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 16 : 20),
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [mycolor.withOpacity(0.2), mycolor.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: mycolor.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 10 : 12),
            decoration: BoxDecoration(
              color: mycolor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: isMobile ? 20 : 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: isMobile ? 20 : 24,
                fontWeight: FontWeight.bold,
                color: mycolor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubSection(String title, IconData icon) {
    final isMobile = MediaQuery.of(context).size.width <= 768;

    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 12 : 16),
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade700, size: isMobile ? 18 : 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard(int stepNumber, String title, String description) {
    final isMobile = MediaQuery.of(context).size.width <= 768;

    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 10 : 12),
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: isMobile ? 28 : 30,
            height: isMobile ? 28 : 30,
            decoration: BoxDecoration(
              color: mycolor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                stepNumber.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 12 : 14,
                ),
              ),
            ),
          ),
          SizedBox(width: isMobile ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: isMobile ? 13 : 14,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String content, Color color) {
    final isMobile = MediaQuery.of(context).size.width <= 768;

    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 12 : 16),
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  FeatherIcons.info,
                  color: Colors.white,
                  size: isMobile ? 14 : 16,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: isMobile ? 13 : 14,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTroubleshootingItem(String problem, String solution) {
    final isMobile = MediaQuery.of(context).size.width <= 768;

    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        title: Text(
          problem,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isMobile ? 14 : 16,
            color: Colors.grey.shade800,
          ),
        ),
        leading: Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.red.shade400,
            shape: BoxShape.circle,
          ),
          child: Icon(
            FeatherIcons.alertTriangle,
            color: Colors.white,
            size: isMobile ? 14 : 16,
          ),
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            child: Text(
              solution,
              style: TextStyle(
                fontSize: isMobile ? 13 : 14,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
