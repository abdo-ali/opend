import React, { useState, useEffect } from "react";
import logo from "../../assets/logo.png";
import { Actor, HttpAgent } from "@dfinity/agent";
import { idlFactory } from "../../../declarations/nft";
import { Principal } from "@dfinity/principal";

function Item(props) {
  const [name, setName] = React.useState();
  const [owner, setOwner] = React.useState();
  const [image, setImage] = React.useState();

  const id = props.id;

  const localHost = "http://localhost:8080/";
  const agent = new HttpAgent({ host: localHost });

  if (process.env.NODE_ENV !== "production") {
    agent.fetchRootKey().catch((err) => {
      console.warn("⚠️ فشل تحميل root key:", err);
      console.warn("لو أنت على الشبكة الحقيقية، تجاهل الرسالة دي.");
    });
  }

  async function loadNFT() {
    const NFTActor = await Actor.createActor(idlFactory, {
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
    } catch (err) {
      console.error("❌ خطأ أثناء جلب اسم الـ NFT:", err);
    }
  }
  useEffect(() => {
    loadNFT();
  }, []);

  return (
    <div className="disGrid-item">
      <div className="disPaper-root disCard-root makeStyles-root-17 disPaper-elevation1 disPaper-rounded">
        <img
          className="disCardMedia-root makeStyles-image-19 disCardMedia-media disCardMedia-img"
          src={image}
        />
        <div className="disCardContent-root">
          <h2 className="disTypography-root makeStyles-bodyText-24 disTypography-h5 disTypography-gutterBottom">
            {name}
            <span className="purple-text"></span>
          </h2>
          <p className="disTypography-root makeStyles-bodyText-24 disTypography-body2 disTypography-colorTextSecondary">
            Owner: {owner}
          </p>
        </div>
      </div>
    </div>
  );
}

export default Item;
