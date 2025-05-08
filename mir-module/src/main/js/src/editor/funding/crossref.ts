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

export async function fetchFunder(name: string): Promise<FunderItem[]> {
  const response = await fetch(
    `https://api.crossref.org/funders?query=${encodeURIComponent(name)}&rows=5`
  );
  if (!response.ok) throw new Error('Error while fetching Crossref funder');
  const data = (await response.json()) as FunderResponse;
  const total = data.message['total-results'];
  if (!total || total === 0) return [];
  const items: FunderInfo[] = [];
  data.message.items.forEach((r: FunderItem) => {
    items.push({
      name: r.name,
      uri: r.uri,
    });
  });
  return items;
}
