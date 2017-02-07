// Bruh!


// To run, `javac Bruh.java`
// then `java Bruh <keystoreFile> <alias> [<keystorePassword>]`

class Bruh {


	public static void main(String[] args) {

		String fileName = "geoserver.jceks";
		char[] password = "This is the password. I repeat...".toCharArray();
		String alias = "config:password:key";

		try {
			java.io.FileInputStream fis = new java.io.FileInputStream(fileName);
			java.security.KeyStore ks = java.security.KeyStore.getInstance("JCEKS");
			ks.load(fis, password);
			javax.crypto.SecretKey secretKey = (javax.crypto.SecretKey) ks.getKey(alias, password);
			System.out.println(new java.math.BigInteger(1, secretKey.getEncoded()).toString(16));
		} catch (Throwable t) {
		}

	} // main() OUT


} // class OUT
