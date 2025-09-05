import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/models/dispatch_models.dart';

class DispatchService {
  static Future<List<CompleteUnit>> getCompleteUnits(
      BuildContext context) async {
    try {
      final userData = await getuserdata();
      final user = jsonDecode(userData);
      final token = user['data']?['token'] ?? '';

      if (token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final url = '${Api.api_url}completeunits';
      final response = await httpget(url, token, context);

      if (response != null && response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        return data.map((json) => CompleteUnit.fromJson(json)).toList();
      } else {
        throw Exception(
            response?['message'] ?? 'Failed to fetch complete units');
      }
    } catch (e) {
      throw Exception('Error fetching complete units: ${e.toString()}');
    }
  }

  static Future<List<MovementHistory>> getMovementHistory(
      String vehicleId, BuildContext context) async {
    try {
      final userData = await getuserdata();
      final user = jsonDecode(userData);
      final token = user['data']?['token'] ?? '';

      if (token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final url = '${Api.api_url}movementhistory/$vehicleId';
      final response = await httpget(url, token, context);

      if (response != null && response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        return data.map((json) => MovementHistory.fromJson(json)).toList();
      } else {
        throw Exception(
            response?['message'] ?? 'Failed to fetch movement history');
      }
    } catch (e) {
      throw Exception('Error fetching movement history: ${e.toString()}');
    }
  }

  static Future<List<RoutingHistory>> getRoutingHistory(
      String vehicleId, BuildContext context) async {
    try {
      final userData = await getuserdata();
      final user = jsonDecode(userData);
      final token = user['data']?['token'] ?? '';

      if (token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final url = '${Api.api_url}routinghistory/$vehicleId';
      final response = await httpget(url, token, context);

      if (response != null && response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        return data.map((json) => RoutingHistory.fromJson(json)).toList();
      } else {
        throw Exception(
            response?['message'] ?? 'Failed to fetch routing history');
      }
    } catch (e) {
      throw Exception('Error fetching routing history: ${e.toString()}');
    }
  }
}
