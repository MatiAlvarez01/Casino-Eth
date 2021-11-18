import { ethers, Contract } from "ethers";
import Ruleta from "./Ruleta.json";

const getBlockchain = () => 
    new Promise((resolve, reject) => {
        window.addEventListener("load", async () => {
            if(window.ethereum) {
                await window.ethereum.enable();
                const provider = new ethers.providers.Web3Provider(window.ethereum);
                const signer = provider.getSigner();
                const signerAddress = await signer.getAddress();
                const ruleta = new Contract(
                    Ruleta.address,
                    Ruleta.abi,
                    signer
                );
                resolve({signerAddress, ruleta});
            }
            resolve({signerAddress: undefined, ruleta: undefined})
        })
    })

export default getBlockchain;