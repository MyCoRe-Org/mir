export type FunderId = {
  type: string;
  value: string;
};

export type Funder = {
  name: string;
  id: FunderId;
};

export type Project = {
  title: string;
  id: string;
  uri?: string;
  funder?: Funder;
};
