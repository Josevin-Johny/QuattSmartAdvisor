// QuattProducts.ts
// Quatt's product catalog based on their website

export interface QuattProduct {
  id: string;
  name: string;
  shortDescription: string;
  tagline: string;
  available: boolean; // Smart Advisor available for this product
  icon: string; // System icon name for now
}

export const QUATT_PRODUCTS: QuattProduct[] = [
  {
    id: 'hybrid-heat-pump',
    name: 'Hybrid Heat Pump',
    shortDescription: 'The most powerful hybrid heat pump.',
    tagline: 'Save up to €1,500 per year',
    available: true, // This one gets Smart Advisor
    icon: 'flame.fill'
  },
  {
    id: 'full-electric',
    name: 'Full Electric Heat Pump',
    shortDescription: 'Completely electric heating solution',
    tagline: 'Save up to €1,800 per year',
    available: false,
    icon: 'bolt.fill'
  },
  {
    id: 'chill',
    name: 'Quatt Chill',
    shortDescription: 'Cooling like an air conditioner with a heat pump',
    tagline: 'Up to 40 m² per Chill',
    available: false,
    icon: 'snowflake'
  },
  {
    id: 'energy-contract',
    name: 'Dynamic Energy Contract',
    shortDescription: '100% green electricity',
    tagline: '20% cheaper energy',
    available: false,
    icon: 'leaf.fill'
  },
  {
    id: 'home-battery',
    name: 'Home Battery',
    shortDescription: 'The modular smart home battery',
    tagline: 'Up to €2,110 per year',
    available: false,
    icon: 'sun.max.fill'
  }
];