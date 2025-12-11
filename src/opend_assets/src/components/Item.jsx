import React, { useState, useEffect } from "react";
import logo from "../../assets/logo.png";
import { Actor, HttpAgent } from "@dfinity/agent";
import { idlFactory } from "../../../declarations/nft";
import { Principal } from "@dfinity/principal";
import Button from "./Button";
import PriceLabel from "./PriceLabel";
import { opend } from "../../../declarations/opend";
import CURRENT_USER_ID from "../index";

function Item(props) {
  const [name, setName] = useState();
  const [owner, setOwner] = useState();
  const [image, setImage] = useState();
  const [button, setButton] = useState();
  const [priceInput, setPriceInput] = useState();
  const [loaderHidden, setLoaderHidden] = useState(true);
  const [blurStyle, setBlurStyle] = useState();
  const [sellStatus, setSellStatus] = useState();
  const [priceLabel, setPriceLabel] = useState();

  const id = props.id;

  const localHost = "http://localhost:8080/";
  const agent = new HttpAgent({ host: localHost });
  let NFTActor;

  if (process.env.NODE_ENV !== "production") {
    agent.fetchRootKey().catch((err) => {
      console.warn("⚠️ فشل تحميل root key:", err);
      console.warn("لو أنت على الشبكة الحقيقية، تجاهل الرسالة دي.");
    });
  }
  // this function to load the NFT data from the canister id
  async function loadNFT() {
    NFTActor = await Actor.createActor(idlFactory, {
      agent,
      canisterId: id,
    });

    console.log("NFT Actor:", NFTActor);

    try {
      const name = await NFTActor.getName();
      const owner = await NFTActor.getOwner();
      const imageData = await NFTActor.getContent();
      const imagecontent = new Uint8Array(imageData);
      const image = URL.createObjectURL(
        new Blob([imagecontent.buffer], { type: "image/png" })
      );

      setName(name);
      setOwner(owner.toText());
      setImage(image);

      if (props.role == "collection") {
        const nftIsListed = await opend.isListed(id);
        if (nftIsListed) {
          setButton("OpenD");
          setBlurStyle({ filter: "blur(4px)" });
          setSellStatus("Listed");
        } else {
          setButton(<Button handleClick={handelSell} text="Sell" />);
        }
      } else if (props.role == "discover") {
        const originalOwner = await opend.getOriginalOwner(id);
        if (originalOwner.toText() != CURRENT_USER_ID.toText()) {
          setButton(<Button handleClick={handelBuy} text="Buy" />);
        }

        const price = await opend.getListingNFTPrice(id);
        setPriceLabel(<PriceLabel price={price.toString()} />);
      }
    } catch (err) {
      console.error("❌ خطأ أثناء جلب اسم الـ NFT:", err);
    }
  }

  useEffect(() => {
    loadNFT();
  }, []);

  let price;
  function handelSell() {
    console.log("clicked");
    setPriceInput(
      <input
        placeholder="Price in DANG"
        type="number"
        className="price-input"
        value={price}
        onChange={(e) => (price = e.target.value)}
      />
    );
    setButton(<Button handleClick={sellItem} text="Confirm" />);
  }

  async function sellItem() {
    setBlurStyle({ filter: "blur(4px)" });
    setLoaderHidden(false);
    console.log("confirm clicked with price: " + price);
    const listingResult = await opend.listItem(id, Number(price));
    console.log("Listing Result: ", listingResult);

    if (listingResult == "success") {
      const opendCanisterId = await opend.getOpendCanisterID();
      const transferResult = await NFTActor.transferOwnership(opendCanisterId);
      console.log("Transfer Result: ", transferResult);
      if (transferResult == "success.") {
        setLoaderHidden(true);
        setButton();
        setPriceInput();
        setOwner("opend");
        setSellStatus("Listed");
      }
    }
  }

  async function handelBuy() {
    console.log("Buy clicked");
  }

  return (
    <div className="disGrid-item">
      <div className="disPaper-root disCard-root makeStyles-root-17 disPaper-elevation1 disPaper-rounded">
        <img
          className="disCardMedia-root makeStyles-image-19 disCardMedia-media disCardMedia-img"
          src={image}
          style={blurStyle}
        />
        <div hidden={loaderHidden} className={`lds-ellipsis`}>
          <div></div>
          <div></div>
          <div></div>
          <div></div>
        </div>
        <div className="disCardContent-root">
          {priceLabel}
          <h2 className="disTypography-root makeStyles-bodyText-24 disTypography-h5 disTypography-gutterBottom">
            {name}
            <span className="purple-text"> {sellStatus}</span>
          </h2>
          <p className="disTypography-root makeStyles-bodyText-24 disTypography-body2 disTypography-colorTextSecondary">
            Owner: {owner}
          </p>
          {priceInput}
          {button}
        </div>
      </div>
    </div>
  );
}

export default Item;
