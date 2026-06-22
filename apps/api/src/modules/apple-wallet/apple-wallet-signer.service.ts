import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { readFileSync } from 'fs';
import forge from 'node-forge';
import { resolve } from 'path';
import { PKPass } from 'passkit-generator';
import {
  AppleWalletPassAssets,
  AppleWalletPassPayload
} from './apple-wallet.types';

@Injectable()
export class AppleWalletSignerService {
  constructor(private readonly configService: ConfigService) {}

  async sign(
    payload: AppleWalletPassPayload,
    assets: AppleWalletPassAssets
  ): Promise<Buffer> {
    try {
      const certificates = this.loadCertificates();
      const pass = new PKPass(
        {
          ...assets,
          'pass.json': Buffer.from(JSON.stringify(payload))
        },
        certificates
      );

      return pass.getAsBuffer();
    } catch {
      throw new Error('Apple Wallet pass signing failed');
    }
  }

  private loadCertificates() {
    const certificatePath = this.requireConfig(
      'APPLE_WALLET_CERTIFICATE_PATH'
    );
    const certificatePassword = this.requireConfig(
      'APPLE_WALLET_CERTIFICATE_PASSWORD',
      false
    );
    const wwdrCertificatePath = this.requireConfig(
      'APPLE_WALLET_WWDR_CERTIFICATE_PATH'
    );

    try {
      const pkcs12 = readFileSync(resolve(certificatePath));
      const wwdr = readFileSync(resolve(wwdrCertificatePath));
      const { signerCert, signerKey } = this.extractSigner(
        pkcs12,
        certificatePassword
      );

      return {
        wwdr: this.certificateToPem(wwdr),
        signerCert,
        signerKey
      };
    } catch {
      throw new Error(
        'Apple Wallet certificates could not be loaded or parsed from the configured paths'
      );
    }
  }

  private extractSigner(pkcs12Buffer: Buffer, password: string) {
    const asn1 = forge.asn1.fromDer(pkcs12Buffer.toString('binary'));
    const pkcs12 = forge.pkcs12.pkcs12FromAsn1(asn1, false, password);
    const keyBags = [
      ...(pkcs12.getBags({
        bagType: forge.pki.oids.pkcs8ShroudedKeyBag
      })[forge.pki.oids.pkcs8ShroudedKeyBag] ?? []),
      ...(pkcs12.getBags({ bagType: forge.pki.oids.keyBag })[
        forge.pki.oids.keyBag
      ] ?? [])
    ];
    const privateKey = keyBags.find((bag) => bag.key)?.key;
    const certificateBags =
      pkcs12.getBags({ bagType: forge.pki.oids.certBag })[
        forge.pki.oids.certBag
      ] ?? [];

    if (!privateKey) {
      throw new Error('Signer key missing');
    }

    const signerCertificate = certificateBags
      .map((bag) => bag.cert)
      .find((certificate) =>
        certificate ? this.matchesPrivateKey(certificate, privateKey) : false
      );

    if (!signerCertificate) {
      throw new Error('Signer certificate missing');
    }

    return {
      signerCert: Buffer.from(forge.pki.certificateToPem(signerCertificate)),
      signerKey: Buffer.from(forge.pki.privateKeyToPem(privateKey))
    };
  }

  private matchesPrivateKey(
    certificate: forge.pki.Certificate,
    privateKey: forge.pki.PrivateKey
  ) {
    const publicKey = certificate.publicKey as forge.pki.rsa.PublicKey;
    const rsaPrivateKey = privateKey as forge.pki.rsa.PrivateKey;

    return (
      Boolean(publicKey.n && publicKey.e && rsaPrivateKey.n && rsaPrivateKey.e) &&
      publicKey.n.toString(16) === rsaPrivateKey.n.toString(16) &&
      publicKey.e.toString(16) === rsaPrivateKey.e.toString(16)
    );
  }

  private certificateToPem(certificate: Buffer) {
    const text = certificate.toString('utf8');

    if (text.includes('BEGIN CERTIFICATE')) {
      return certificate;
    }

    const asn1 = forge.asn1.fromDer(certificate.toString('binary'));
    return Buffer.from(
      forge.pki.certificateToPem(forge.pki.certificateFromAsn1(asn1))
    );
  }

  private requireConfig(name: string, trim = true) {
    const configured = this.configService.get<string>(name) ?? '';
    const value = trim ? configured.trim() : configured;

    if (!value) {
      throw new Error(`${name} is required when APPLE_WALLET_ENABLED=true`);
    }

    return value;
  }
}
