declare namespace NodeJS {
  interface ProcessEnv {
    readonly PUBLIC_KEY: string;
    readonly PRIVATE_KEY: string;
    readonly GOERLI_URL: string;
    readonly ETHERSCAN_API_KEY: string;
    readonly COINMARKETCAP_API_KEY: string;
  }
}
