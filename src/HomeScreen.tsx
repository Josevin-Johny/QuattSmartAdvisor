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
        {/* Icon placeholder - in real app, use images */}
        <View style={[
          styles.iconContainer,
          item.available ? styles.activeIcon : styles.inactiveIcon
        ]}>
          <Text style={styles.iconText}>
            {item.name.charAt(0)}
          </Text>
        </View>

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
      <StatusBar barStyle="light-content" />
      
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
    backgroundColor: '#0A0E27', // Dark theme like Quatt app
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
    backgroundColor: '#1A1F3A',
    borderRadius: 16,
    marginBottom: 16,
    overflow: 'hidden',
  },
  cardContent: {
    flexDirection: 'row',
    padding: 16,
    alignItems: 'center',
  },
  iconContainer: {
    width: 60,
    height: 60,
    borderRadius: 12,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 16,
  },
  activeIcon: {
    backgroundColor: '#00D9FF', // Quatt blue/cyan
  },
  inactiveIcon: {
    backgroundColor: '#2A3048',
  },
  iconText: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#FFFFFF',
  },
  textContent: {
    flex: 1,
  },
  productName: {
    fontSize: 18,
    fontWeight: '600',
    color: '#FFFFFF',
    marginBottom: 4,
  },
  productDescription: {
    fontSize: 14,
    color: '#B0B0B0',
    marginBottom: 4,
  },
  productTagline: {
    fontSize: 13,
    color: '#00D9FF',
    fontWeight: '500',
  },
  badge: {
    marginTop: 8,
    paddingHorizontal: 10,
    paddingVertical: 4,
    backgroundColor: 'rgba(0, 217, 255, 0.2)',
    borderRadius: 8,
    alignSelf: 'flex-start',
  },
  badgeText: {
    fontSize: 11,
    color: '#00D9FF',
    fontWeight: '600',
  },
  arrow: {
    marginLeft: 8,
  },
  arrowText: {
    fontSize: 32,
    color: '#A0A0A0',
    fontWeight: '300',
  },
});
