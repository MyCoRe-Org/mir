import { FunderInfo } from './types';

type FunderItem = {
  name: string;
  uri: string;
};

type FunderResponse = {
  status: string;
  message: {
    items: FunderItem[];
    'total-results': number;
  };
};

const API_URL = 'https://api.crossref.org/funders';

export async function fetchFunder(name: string): Promise<FunderInfo[]> {
  const response = await fetch(
    `${API_URL}?query=${encodeURIComponent(name)}&rows=5`
  );
  if (!response.ok) throw new Error('Error while fetching Crossref funder');
  const data = (await response.json()) as FunderResponse;
  const total = data.message['total-results'];
  if (!total) return [];
  return data.message.items.map(r => ({
    name: r.name,
    uri: r.uri,
  }));
}
