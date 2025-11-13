// HomeScreen.tsx
import React from 'react';
import {
  View,
  Text,
  FlatList,
  TouchableOpacity,
  StyleSheet,
  SafeAreaView,
  StatusBar,
  Image,
} from 'react-native';
import { NativeModules } from 'react-native';
import { QUATT_PRODUCTS, QuattProduct } from './QuattProducts';

const { SmartAdvisorModule } = NativeModules;

export default function HomeScreen() {
  const handleProductPress = (product: QuattProduct) => {
    if (product.available) {
      // Open native Smart Advisor module
      SmartAdvisorModule.present();
    } else {
      // Could show an alert: "Coming in next sprint!"
      console.log(`${product.name} - Smart Advisor coming soon`);
    }
  };

  const renderProduct = ({ item }: { item: QuattProduct }) => (
    <TouchableOpacity
      style={styles.productCard}
      onPress={() => handleProductPress(item)}
      activeOpacity={0.7}
    >
      <View style={styles.cardContent}>
        {/* Product Image */}
        <Image
          source={item.image}
          style={styles.productImage}
          resizeMode="cover"
        />

        <View style={styles.textContent}>
          <Text style={styles.productName}>{item.name}</Text>
          <Text style={styles.productDescription}>
            {item.shortDescription}
          </Text>
          <Text style={styles.productTagline}>{item.tagline}</Text>
          
          {item.available && (
            <View style={styles.badge}>
              <Text style={styles.badgeText}>Smart Advisor Available</Text>
            </View>
          )}
        </View>

        <View style={styles.arrow}>
          <Text style={styles.arrowText}>›</Text>
        </View>
      </View>
    </TouchableOpacity>
  );

  return (
    <SafeAreaView style={styles.container}>
      <StatusBar barStyle="light-content" backgroundColor="#0A0E27" />
      
      <View style={styles.header}>
        <Text style={styles.headerTitle}>Quatt Products</Text>
        <Text style={styles.headerSubtitle}>
          Explore our smart home energy solutions
        </Text>
      </View>

      <FlatList
        data={QUATT_PRODUCTS}
        renderItem={renderProduct}
        keyExtractor={(item) => item.id}
        contentContainerStyle={styles.listContent}
      />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#000000', // Pure black theme
  },
  header: {
    padding: 24,
    paddingTop: 16,
  },
  headerTitle: {
    fontSize: 32,
    fontWeight: 'bold',
    color: '#FFFFFF',
    marginBottom: 8,
  },
  headerSubtitle: {
    fontSize: 16,
    color: '#A0A0A0',
  },
  listContent: {
    padding: 16,
    paddingBottom: 32,
  },
  productCard: {
    backgroundColor: '#000000', // Pure black background
    borderRadius: 12,
    marginBottom: 16,
    overflow: 'hidden',
    borderWidth: 0.2,
    borderColor: '#FFFFFF',
    shadowColor: '#000000',
    shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.8,
    shadowRadius: 12,
    elevation: 15, // Android shadow/3D effect
  },
  cardContent: {
    flexDirection: 'row',
    padding: 12,
    alignItems: 'center',
    height: 130,
  },
  productImage: {
    width: 80,
    height: 80,
    borderRadius: 8,
    backgroundColor: '#000000',
    marginRight: 12,
  },
  textContent: {
    flex: 1,
    justifyContent: 'center',
  },
  productName: {
    fontSize: 16,
    fontWeight: '600',
    color: '#FFFFFF',
    marginBottom: 2,
  },
  productDescription: {
    fontSize: 13,
    color: '#B0B0B0',
    marginBottom: 2,
  },
  productTagline: {
    fontSize: 12,
    color: '#666666',
    fontWeight: '500',
    marginTop: 6,
  },
  badge: {
    marginTop: 6,
    paddingHorizontal: 8,
    paddingVertical: 3,
    backgroundColor: 'rgba(0, 217, 255, 0.2)',
    borderRadius: 6,
    alignSelf: 'flex-start',
  },
  badgeText: {
    fontSize: 10,
    color: '#00D9FF',
    fontWeight: '600',
  },
  arrow: {
    paddingLeft: 8,
  },
  arrowText: {
    fontSize: 28,
    color: '#A0A0A0',
    fontWeight: '300',
  },
});
