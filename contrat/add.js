// Replace this with your contract's actual ABI
const contractABI = [
  // Paste your full ABI JSON array here
];

const contractAddress = "0xYourDeployedContractAddress"; // Replace with your deployed contract address

let web3;
let contract;

window.addEventListener("load", async () => {
  if (window.ethereum) {
    web3 = new Web3(window.ethereum);
    await window.ethereum.request({ method: "eth_requestAccounts" });

    contract = new web3.eth.Contract(contractABI, contractAddress);

    loadProperties();
  } else {
    alert("Please install MetaMask to use this DApp");
  }
});

async function listProperty() {
  const priceInput = document.getElementById("priceInput").value;
  if (!priceInput || isNaN(priceInput) || priceInput <= 0) {
    alert("Please enter a valid price");
    return;
  }

  const accounts = await web3.eth.getAccounts();
  const priceInWei = web3.utils.toWei(priceInput, "ether");

  try {
    await contract.methods.listProperty(priceInWei).send({ from: accounts[0] });
    alert("✅ Property Listed Successfully!");
    document.getElementById("priceInput").value = "";
    loadProperties();
  } catch (error) {
    console.error(error);
    alert("❌ Failed to list property");
  }
}

async function loadProperties() {
  const container = document.getElementById("propertyList");
  container.innerHTML = "";

  try {
    const propertyIds = await contract.methods.getUnsoldPropertyIds().call();
    if (propertyIds.length === 0) {
      container.innerHTML = "<p>No properties available.</p>";
      return;
    }

    for (let id of propertyIds) {
      const p = await contract.methods.getProperty(id).call();

      const card = document.createElement("div");
      card.className = "property-card";
      card.innerHTML = `
        <p><b>ID:</b> ${p[0]}</p>
        <p><b>Seller:</b> ${p[1]}</p>
        <p><b>Price:</b> ${web3.utils.fromWei(p[3], "ether")} ETH</p>
        <button onclick="buyProperty(${p[0]}, '${p[3]}')">Buy</button>
      `;
      container.appendChild(card);
    }
  } catch (err) {
    console.error("Error loading properties:", err);
    container.innerHTML = "<p>Error loading property list.</p>";
  }
}

async function buyProperty(id, priceInWei) {
  const accounts = await web3.eth.getAccounts();
  try {
    await contract.methods.buyProperty(id).send({
      from: accounts[0],
      value: priceInWei
    });
    alert("✅ Property Purchased!");
    loadProperties();
  } catch (error) {
    console.error(error);
    alert("❌ Failed to buy property");
  }
}
