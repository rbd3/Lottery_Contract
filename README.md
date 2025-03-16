<a name="readme-top"></a>

<div align="center">

  <img src=" public/ lottery-smart-contract.webp" alt="logo" width="140"  height="auto" />
  <br/>

  <h3><b>DECENTRALIZED LOTTERY CONTRACT</b></h3>

</div>

<!-- TABLE OF CONTENTS -->

# 📗 Table of Contents

- [📖 About the Project](#about-project)
  - [🛠 Built With](#built-with)
    - [Tech Stack](#tech-stack)
    - [Key Features](#key-features)
- [💻 Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Setup](#setup)
  - [Install](#install)
  - [Usage](#usage)
  - [Run tests](#run-tests)
- [👥 Authors](#authors)
- [🔭 Future Features](#future-features)
- [🤝 Contributing](#contributing)
- [⭐️ Show your support](#support)
- [🙏 Acknowledgements](#acknowledgements)
- [📝 License](#license)

<!-- PROJECT DESCRIPTION -->

# 📖 DECENTRALIZED LOTTERY CONTRACT <a name="about-project"></a>

This smart contract, named Raffle, is a decentralized lottery system built on the Ethereum blockchain using Solidity. It leverages Chainlink's Verifiable Random Function (VRF) to ensure fair and transparent selection of winners. The contract allows participants to enter the raffle by sending a specified amount of Ether, and after a predefined interval, a winner is randomly selected and awarded the entire balance of the contract.

## 🛠 Built With <a name="built-with"></a>

### Tech Stack <a name="tech-stack"></a>

  <ul>
    <li><a href="https://book.getfoundry.sh/">Foundry</a></li>
    <li><a href="https://soliditylang.org/">Solidity</a></li>
    <li><a href="https://docs.chain.link/vrf/v2-5/getting-started">Chainlink VRF</a></li>
  </ul>
<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- Features -->

### Key Features <a name="key-features"></a>

- **Decentralized and Transparent: The use of Chainlink VRF ensures that the selection of the winner is random and verifiable, eliminating any possibility of manipulation.**

- **Automated Winner Selection: The contract automatically checks if the conditions for selecting a winner are met (e.g., time interval has passed, there are participants, and the contract has a balance). If conditions are met, it triggers the random selection process.**

- **Secure and Efficient: The contract includes various checks and error handling to ensure that only valid transactions are processed, and funds are securely transferred to the winner.**

- **Immutable Parameters: Key parameters such as the entrance fee, interval duration, and VRF configuration are set during contract deployment and cannot be altered, ensuring fairness and consistency.**

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- GETTING STARTED -->

## 💻 Getting Started <a name="getting-started"></a>

To get a local copy up and running, follow these steps.

### Prerequisites

In order to run this project you need to install the following items:

- Foundry
- Solidity extension

### Install

Install this project by using:

```
git clone https://github.com/rbd3/Lottery_Contract.git
cd Lottery_Contract
make install
```

### Run tests

To run tests, run the following command:


```
make test
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- AUTHORS -->

## 👥 Authors <a name="authors"></a>

👤 **Andry Narson**

- GitHub: [@rbd3](https://github.com/rbd3)
- LinkedIn: [@Andry Narson](https://linkedin.com/in/andry-rabedesana)


<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- FUTURE FEATURES -->

## 🔭 Future Features <a name="future-features"></a>

Here are some potential future features that could be added to the Raffle Lottery Smart Contract to enhance its functionality and user experience:

- **User-Friendly Interface: Develop a frontend (web or mobile) to allow users to interact with the raffle contract seamlessly. Users can enter the raffle, view their entries, and check the status of the raffle without needing to interact directly with the blockchain.**

- **Real-Time Updates: Display real-time updates on the raffle state, such as the number of participants, time remaining until the next draw, and the recent winner.**

- **Wallet Integration: Integrate with popular wallets like MetaMask or WalletConnect to allow users to connect their wallets and participate in the raffle easily.**

- **Cross-Chain Raffles: Extend the contract to support multiple blockchains (e.g., Polygon, Binance Smart Chain, Avalanche) to reach a broader audience and reduce gas fees for participants.**

- **Automated Raffle Rounds: Implement a feature where the raffle automatically starts a new round after a winner is selected, without requiring manual intervention.**

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTRIBUTING -->

## 🤝 Contributing <a name="contributing"></a>

Contributions, issues, and feature requests are welcome!

Feel free to check the [issues page](https://github.com/rbd3/Lottery_Contract/issues/).

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- SUPPORT -->

## ⭐️ Show your support <a name="support"></a>

Give a star⭐️ or a thumbs up 👍 if you like this project! You can visit my GitHub profile for more of my projects.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- ACKNOWLEDGEMENTS -->

## 🙏 Acknowledgments <a name="acknowledgements"></a>

- My family who supported me
- Patrick Collins

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- LICENSE -->

## 📝 License <a name="license"></a>

This project is [MIT](./LICENSE) licensed.

<p align="right">(<a href="#readme-top">back to top</a>)</p>
