// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductAdapter extends TypeAdapter<Product> {
  @override
  final int typeId = 0;

  @override
  Product read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Product(
      id: fields[0] as int,
      categoryId: fields[1] as int,
      name: fields[2] as String,
      slug: fields[3] as String,
      description: fields[4] as String?,
      price: fields[5] as double,
      stockQuantity: fields[6] as int,
      minimumStock: fields[7] as int,
      barcode: fields[8] as String?,
      imagePath: fields[9] as String?,
      purchasePrice: fields[10] as double,
      salePrice: fields[11] as double,
      category: fields[12] as Category?,
      transactions: (fields[13] as List?)?.cast<Transaction>(),
      createdAt: fields[14] as DateTime?,
      updatedAt: fields[15] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Product obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.categoryId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.slug)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.price)
      ..writeByte(6)
      ..write(obj.stockQuantity)
      ..writeByte(7)
      ..write(obj.minimumStock)
      ..writeByte(8)
      ..write(obj.barcode)
      ..writeByte(9)
      ..write(obj.imagePath)
      ..writeByte(10)
      ..write(obj.purchasePrice)
      ..writeByte(11)
      ..write(obj.salePrice)
      ..writeByte(12)
      ..write(obj.category)
      ..writeByte(13)
      ..write(obj.transactions)
      ..writeByte(14)
      ..write(obj.createdAt)
      ..writeByte(15)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
