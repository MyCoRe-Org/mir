import { Affiliation } from './types';

const API_URL = 'https://api.ror.org/v2/organizations';

interface RORName {
  types: string[];
  value: string;
}

interface RORItem {
  id: string;
  names: RORName[];
}

interface RORResponse {
  items: RORItem[];
}

async function fetchRORItems(
  query: string,
  signal: AbortSignal
): Promise<RORItem[]> {
  const response = await fetch(
    `${API_URL}?query=${encodeURIComponent(query)}`,
    {
      signal,
    }
  );
  if (!response.ok) {
    const text = await response.text().catch(() => '');
    throw new Error(`ROR API error (${response.status}): ${text}`);
  }
  const data: RORResponse = await response.json();
  return data.items;
}

export async function fetchAffiliation(
  query: string,
  signal: AbortSignal
): Promise<Affiliation[]> {
  if (!query.trim()) return [];
  const items = await fetchRORItems(query, signal);
  const affiliations: Affiliation[] = items.map(item => ({
    id: item.id,
    name:
      item.names.find(n => n.types.includes('ror_display'))?.value ||
      item.names[0]?.value ||
      'Unknown',
  }));
  return affiliations;
}
