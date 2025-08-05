import { Funder } from './types';

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
const MAX_RESULTS = 5;

async function fetchFunderData(
  name: string,
  signal: AbortSignal
): Promise<FunderResponse> {
  const response = await fetch(
    `${API_URL}?query=${encodeURIComponent(name)}&rows=${MAX_RESULTS}`,
    { signal }
  );
  if (!response.ok) {
    throw new Error(
      `API request failed: ${response.status} ${response.statusText}`
    );
  }
  return (await response.json()) as FunderResponse;
}

function parseFunderResponse(data: FunderResponse): Funder[] {
  const items = data.message.items;
  if (!items.length) return [];
  return data.message.items.map(item => ({
    name: item.name,
    id: {
      type: 'Crossref Funder ID',
      value: item.uri,
    },
  }));
}

export async function fetchFunder(
  name: string,
  signal: AbortSignal
): Promise<Funder[]> {
  if (!name.trim()) return [];
  const data = await fetchFunderData(name, signal);
  return parseFunderResponse(data);
}
