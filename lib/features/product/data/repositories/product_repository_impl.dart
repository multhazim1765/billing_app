import 'package:fpdart/fpdart.dart';
import '../../../../core/data/hive_database.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../default_products.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  String _normalizeBarcode(String value) => value.trim().toLowerCase();

  @override
  Future<Either<Failure, List<Product>>> getProducts() async {
    try {
      final box = HiveDatabase.productBox;
      final products = box.values.map((model) => model.toEntity()).toList();
      return Right(products);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Product>> getProductByBarcode(String barcode) async {
    try {
      final box = HiveDatabase.productBox;
      final normalizedBarcode = _normalizeBarcode(barcode);
      final product = box.values.cast<ProductModel?>().firstWhere(
        (element) =>
            element != null &&
            _normalizeBarcode(element.barcode) == normalizedBarcode,
        orElse: () => null,
      );
      if (product == null) {
        return const Left(CacheFailure('Product not found'));
      }
      return Right(product.toEntity());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addProduct(Product product) async {
    try {
      final box = HiveDatabase.productBox;
      final normalizedBarcode = _normalizeBarcode(product.barcode);
      final hasDuplicateBarcode = box.values.any(
        (existing) => _normalizeBarcode(existing.barcode) == normalizedBarcode,
      );
      if (hasDuplicateBarcode) {
        return const Left(CacheFailure('Barcode already exists'));
      }
      // You can use add() or put()
      final model = ProductModel.fromEntity(product);
      await box.put(model.id, model); // Using ID as key
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> seedDefaultProducts() async {
    try {
      final box = HiveDatabase.productBox;
      final existingBarcodes = box.values
          .map((product) => _normalizeBarcode(product.barcode))
          .toSet();

      var addedCount = 0;
      for (final model in kDefaultProducts) {
        final normalizedBarcode = _normalizeBarcode(model.barcode);
        if (existingBarcodes.contains(normalizedBarcode)) {
          continue;
        }

        await box.put(model.id, model);
        existingBarcodes.add(normalizedBarcode);
        addedCount++;
      }

      return Right(addedCount);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateProduct(Product product) async {
    try {
      final box = HiveDatabase.productBox;
      final normalizedBarcode = _normalizeBarcode(product.barcode);
      final hasDuplicateBarcode = box.values.any(
        (existing) =>
            _normalizeBarcode(existing.barcode) == normalizedBarcode &&
            existing.id != product.id,
      );
      if (hasDuplicateBarcode) {
        return const Left(CacheFailure('Barcode already exists'));
      }
      final model = ProductModel.fromEntity(product);
      await box.put(model.id, model);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String id) async {
    try {
      final box = HiveDatabase.productBox;
      await box.delete(id);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
