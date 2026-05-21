import 'package:apna_business_app/core/network/dio_client.dart';
import 'package:apna_business_app/data/models/inventory_model.dart';
import 'package:dio/dio.dart';

/// Remote datasource for inventory CRUD.
class InventoryRemoteDataSource {
  InventoryRemoteDataSource(this._dioClient);

  final DioClient _dioClient;

  Future<List<InventoryItemModel>> fetchInventory() async {
    try {
      final response = await _dioClient.dio.get<Map<String, dynamic>>(
        '/api/v1/inventory/',
      );
      final data = response.data ?? <String, dynamic>{};
      final List<dynamic> items =
          data['items'] as List<dynamic>? ?? <dynamic>[];
      return items
          .whereType<Map<String, dynamic>>()
          .map(InventoryItemModel.fromJson)
          .toList(growable: false);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Future<InventoryItemModel> upsertItem(Map<String, dynamic> payload) async {
    try {
      final response = await _dioClient.dio.post<Map<String, dynamic>>(
        '/api/v1/inventory/',
        data: payload,
      );
      return InventoryItemModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Future<void> deleteItem(int id) async {
    try {
      await _dioClient.dio.delete<void>('/api/v1/inventory/$id');
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Future<List<InventoryItemModel>> searchProducts(String query) async {
    try {
      final response = await _dioClient.dio.get<Map<String, dynamic>>(
        '/api/v1/inventory/search',
        queryParameters: <String, dynamic>{'q': query},
      );
      final data = response.data ?? <String, dynamic>{};
      final List<dynamic> items =
          data['items'] as List<dynamic>? ?? <dynamic>[];
      return items
          .whereType<Map<String, dynamic>>()
          .map(InventoryItemModel.fromJson)
          .toList(growable: false);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}
