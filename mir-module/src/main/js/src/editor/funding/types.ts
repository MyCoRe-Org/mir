export type FunderId = {
  type: string;
  value: string;
};

export type Funder = {
  name: string;
  id: FunderId;
};

export type FunderInfo = {
  name: string;
  uri: string;
};

export type Award = {
  title: string;
  number: string;
  uri?: string;
};

export type Funding = {
  funder: Funder;
  award: Award;
};
