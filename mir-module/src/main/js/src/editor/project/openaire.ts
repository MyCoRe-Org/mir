import { Project, Funder } from './types';

type OpenAIREMetadata = {
  fundingtree?:
    | { funder: { id: { $: string }; name: { $: string } } }[]
    | { funder: { id: { $: string }; name: { $: string } } };
  title?: { $: string };
  code?: { $: string };
};

type OpenAIREAPIResponseItem = {
  metadata: {
    'oaf:entity': {
      'oaf:project': OpenAIREMetadata;
    };
  };
};

// enum is currently limited to more famous funders
export enum OpenAIREFunderId {
  EC = 'ec__________::EC',
  NIH = 'nih_________::NIH',
  UKRI = 'ukri________::UKRI',
  NSF = 'nsf_________::NSF',
  FCT = 'fct_________::FCT',
  WT = 'wt__________::WT',
  ANR = 'anr_________::ANR',
  ARC = 'arc_________::ARC',
  NHMRC = 'nhmrc_______::NHMRC',
  NWO = 'nwo_________::NWO',
  FWF = 'fwf_________::FWF',
  TUBITAK = 'tubitakf____::tubitak',
  AKA = 'aka_________::AKA',
  SFI = 'sfi_________::SFI',
  SNSF = 'snsf________::SNSF',
  MZOS = 'irb_hr______::MZOS',
  HRZZ = 'irb_hr______::HRZZ',
}

export type FunderMetadata = {
  name: string;
  doi: string;
};

export const CROSSREF_FUNDERS: Record<OpenAIREFunderId, FunderMetadata> = {
  [OpenAIREFunderId.EC]: {
    name: 'European Commission',
    doi: '10.13039/501100000780',
  },
  [OpenAIREFunderId.NIH]: {
    name: 'National Institutes of Health',
    doi: '10.13039/100000002',
  },
  [OpenAIREFunderId.UKRI]: {
    name: 'UK Research and Innovation',
    doi: '10.13039/100014013',
  },
  [OpenAIREFunderId.NSF]: {
    name: 'National Science Foundation',
    doi: '10.13039/501100001711',
  },
  [OpenAIREFunderId.FCT]: {
    name: 'Fundação para a Ciência e a Tecnologia',
    doi: '10.13039/501100001871',
  },
  [OpenAIREFunderId.WT]: {
    name: 'Wellcome Trust',
    doi: '10.13039/100010269',
  },
  [OpenAIREFunderId.ANR]: {
    name: 'Agence Nationale de la Recherche',
    doi: '10.13039/501100001665',
  },
  [OpenAIREFunderId.ARC]: {
    name: 'Australian Research Council',
    doi: '10.13039/501100000923',
  },
  [OpenAIREFunderId.NHMRC]: {
    name: 'National Health and Medical Research Council',
    doi: '10.13039/501100000925',
  },
  [OpenAIREFunderId.NWO]: {
    name: 'Nederlandse Organisatie voor Wetenschappelijk Onderzoek',
    doi: '10.13039/501100003246',
  },
  [OpenAIREFunderId.FWF]: {
    name: 'Austrian Science Fund',
    doi: '10.13039/501100002428',
  },
  [OpenAIREFunderId.TUBITAK]: {
    name: 'Türkiye Bilimsel ve Teknolojik Araştırma Kurumu',
    doi: '10.13039/501100004410',
  },
  [OpenAIREFunderId.AKA]: {
    name: 'Research Council of Finland',
    doi: '10.13039/501100002341',
  },
  [OpenAIREFunderId.SFI]: {
    name: 'Science Foundation Ireland',
    doi: '10.13039/501100001602',
  },
  [OpenAIREFunderId.SNSF]: {
    name: 'Schweizerischer Nationalfonds',
    doi: '10.13039/501100001711',
  },
  [OpenAIREFunderId.MZOS]: {
    name: 'Ministarstvo Znanosti, Obrazovanja i Sporta',
    doi: '10.13039/501100006588',
  },
  [OpenAIREFunderId.HRZZ]: {
    name: 'Hrvatska Zaklada za Znanost',
    doi: '10.13039/501100004488',
  },
};

function getFunder(funderId: string, fallbackName: string): Funder {
  if (funderId in CROSSREF_FUNDERS) {
    const { name, doi } = CROSSREF_FUNDERS[funderId as OpenAIREFunderId];
    return {
      name,
      id: { type: 'Crossref Funder ID', value: `https://doi.org/${doi}` },
    };
  }
  return {
    name: fallbackName,
    id: { type: 'Other', value: funderId },
  };
}

function getProject(metadata: OpenAIREMetadata): Project {
  return {
    title: metadata.title?.$ ?? 'Untitled',
    id: metadata.code?.$ ?? 'Unknown',
  };
}

type FundingTreeEntry = { funder: { id: { $: string }; name: { $: string } } };

function normalizeFundingtree(
  input: OpenAIREMetadata['fundingtree']
): FundingTreeEntry[] {
  if (!input) return [];
  return Array.isArray(input) ? input : [input];
}

const API_URL = 'https://api.openaire.eu/search/projects';
const DEFAULT_RESULT_SIZE = 5;

export async function fetchProjectByTitle(
  title: string,
  signal: AbortSignal
): Promise<Project[]> {
  const response = await fetch(
    `${API_URL}?name=${encodeURIComponent(
      title
    )}&format=json&size=${DEFAULT_RESULT_SIZE}`,
    { signal }
  );
  if (!response.ok) {
    const text = await response.text().catch(() => '');
    throw new Error(`OpenAIRE API error (${response.status}): ${text}`);
  }
  const data = await response.json();

  const results: OpenAIREAPIResponseItem[] =
    data?.response?.results?.result ?? [];

  const items: Project[] = [];
  for (const result of results) {
    const metadata = result.metadata['oaf:entity']['oaf:project'];
    const fundingtrees = normalizeFundingtree(metadata.fundingtree);
    for (const tree of fundingtrees) {
      const funderId = tree.funder?.id?.$;
      const funderName = tree.funder?.name?.$;
      if (!funderId || !funderName) continue;
      const funder = getFunder(funderId, funderName);
      const project = getProject(metadata);
      if (funderId === OpenAIREFunderId.EC) {
        project.uri = `https://cordis.europa.eu/project/id/${project.id}`;
      }
      items.push({ ...project, funder });
    }
  }

  return items;
}
