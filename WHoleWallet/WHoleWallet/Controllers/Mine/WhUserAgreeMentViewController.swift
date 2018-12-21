//
/*******************************************************************************

        WhUserAgreeMentViewController.swift
        WHoleWallet
   
        Created by ffy on 2018/12/5
        Copyright © 2018年 wormhole. All rights reserved.

********************************************************************************/
    

import UIKit
import WebKit

class WhUserAgreeMentViewController: UIViewController {

    @IBOutlet weak var wkWebView: WKWebView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        wkWebView.loadHTMLString(contentHTML, baseURL: nil)
    }
    
    let contentHTML = "<div data-v-28ae01f9=\"\" data-v-a9fef2c2=\"\" class=\"disclaimer-body\"><p data-v-28ae01f9=\"\" align=\"center\"><strong data-v-28ae01f9=\"\">Wormhole Wallet Disclaimer </strong></p><p data-v-28ae01f9=\"\" align=\"center\"><strong data-v-28ae01f9=\"\"></strong></p><p data-v-28ae01f9=\"\" align=\"left\"><strong data-v-28ae01f9=\"\">\n" +
        "            ANY VISITOR/USER OF THE WEBSITE AND MOBILE APPLICATION OF WORMHOLE\n" +
        "            WALLET UNDERSTANDS AND AGREES TO THE FOLLOWING:\n" +
        "        </strong></p><div data-v-28ae01f9=\"\" class=\"line\"></div><p data-v-28ae01f9=\"\" align=\"left\"><strong data-v-28ae01f9=\"\"></strong></p><p data-v-28ae01f9=\"\" align=\"left\"><strong data-v-28ae01f9=\"\">Article 1</strong></p><p data-v-28ae01f9=\"\">\n" +
        "        Wormhole Wallet is a project intended for developer testing. The goal of\n" +
        "        Wormhole Wallet is to serve as a reference model in the blockchain\n" +
        "        community for companies that are interested in developing related\n" +
        "        technologies. The website and mobile applications of Wormhole Wallet are\n" +
        "        provided on the pre-condition that the users of the website and mobile\n" +
        "        applications of Wormhole Wallet do not violate any of the relevant\n" +
        "        applicable laws and regulations. The users are prohibited to use the\n" +
        "        website and mobile applications provided by Wormhole Wallet for the purpose\n" +
        "        of engaging in any illegal activities, including but not limited to money\n" +
        "        laundering, corruption, Ponzi scheme, terrorism, smuggling and commercial\n" +
        "        bribery; where any user is found to be involved in any of the\n" +
        "        aforementioned illegal activities, Wormhole Wallet will freeze the account\n" +
        "        and immediately report such account to the competent legal authority.\n" +
        "    </p><p data-v-28ae01f9=\"\"><strong data-v-28ae01f9=\"\">Article 2</strong><strong data-v-28ae01f9=\"\"></strong></p><p data-v-28ae01f9=\"\">\n" +
        "        Where a competent legal authority requests Wormhole Wallet to collaborate\n" +
        "        with any investigation relating to any designated user or account, or if\n" +
        "        the account of the user is subject to such measures as closure, freezing,\n" +
        "        or transfer, Wormhole Wallet will, as is required by the competent legal\n" +
        "        authority, assist such authority by providing corresponding data relating\n" +
        "        to the account user, or carrying out the corresponding operation as is\n" +
        "        required by the competent authority, and Wormhole Wallet shall not be held\n" +
        "        liable in any manner whatsoever for any of the aforementioned\n" +
        "        collaborations and any and all losses arising therefrom.\n" +
        "    </p><p data-v-28ae01f9=\"\">\n" +
        "        Wormhole Wallet is not liable to any person for any claim based upon\n" +
        "        termination of an account or disablement of access to any function of\n" +
        "        Wormhole Wallet or removal of any content, including material Wormhole\n" +
        "        Wallet believes, in its sole discretion, that violate applicable laws and\n" +
        "        regulations, the Wormhole Wallet Terms and any other restrictions announced\n" +
        "        by Wormhole Wallet from time to time, regardless of whether such\n" +
        "        termination or disabling has the effect of resulting damages or loss to any\n" +
        "        party.\n" +
        "    </p><p data-v-28ae01f9=\"\"><strong data-v-28ae01f9=\"\">Article 3</strong></p><p data-v-28ae01f9=\"\">\n" +
        "        Wormhole Wallet is not a commercial customer-facing product and it is\n" +
        "        provided only for developer testing. Please do not use Wormhole Wallet to\n" +
        "        conduct any significant amount fund transfer. Wormhole Wallet does not\n" +
        "        guarantee the security of any fund transfer through the use of Wormhole\n" +
        "        Wallet.\n" +
        "    </p><p data-v-28ae01f9=\"\">\n" +
        "        In no event should Wormhole Wallet becomes obligated to be involved in\n" +
        "        disputes between users, or between users and any third party relating to\n" +
        "        the use of Wormhole Wallet. Wormhole Wallet may be upgraded or under\n" +
        "        maintenance routinely so that our developers of Wormhole Wallet can test\n" +
        "        their latest idea, plan or experiment.\n" +
        "    </p><p data-v-28ae01f9=\"\">\n" +
        "        Wormhole Wallet makes no representation or warrants as to the adequacy,\n" +
        "        timeliness, accuracy, or completeness of any information or any website\n" +
        "        linked through hyperlink on the website and mobile applications of Wormhole\n" +
        "        Wallet, including but not limited to: the information of the projects\n" +
        "        launched by users through Wormhole Wallet’s platform. Wormhole Wallet does\n" +
        "        not endorse any information or data that the users submit to us. When you\n" +
        "        use Wormhole Wallet, you release Wormhole Wallet from claims, damages, and\n" +
        "        demands of every kind, known or unknown, suspected or unsuspected,\n" +
        "        disclosed or undisclosed, arising out of or in any way related to such\n" +
        "        disputes and your use of Wormhole Wallet. All information and data you\n" +
        "        access through Wormhole Wallet is at your own risk. You are solely\n" +
        "        responsible for any resulting damages or loss to any party.\n" +
        "    </p><p data-v-28ae01f9=\"\">\n" +
        "        Wormhole Wallet will not assume any joint or several liabilities for the\n" +
        "        users’ actions where they have violated any applicable laws.\n" +
        "    </p><p data-v-28ae01f9=\"\"><strong data-v-28ae01f9=\"\"></strong></p><p data-v-28ae01f9=\"\"><strong data-v-28ae01f9=\"\">Article </strong><strong data-v-28ae01f9=\"\">4</strong><strong data-v-28ae01f9=\"\"></strong></p><p data-v-28ae01f9=\"\">\n" +
        "        Wormhole Wallet only undertakes obligations expressly set forth in the\n" +
        "        Wormhole Wallet Terms. You acknowledge and accept that, to the maximum\n" +
        "        extent permitted by the applicable laws, Wormhole Wallet is provided on an\n" +
        "        “as is”, “as available” and “with all faults” basis without any\n" +
        "        representation or warranty, whether express, implied, or statutory. To the\n" +
        "        maximum extent permitted by applicable law, Wormhole Wallet expressly\n" +
        "        disclaims and you waive all warranties of any kind, whether express or\n" +
        "        implied, including without limitation, implied warranties of title,\n" +
        "        merchantability, fitness for a particular purpose and/or non-infringement\n" +
        "        as to Wormhole Wallet, including the information, content and materials\n" +
        "        contained therein. Wormhole Wallet shall not be held liable for any\n" +
        "        malfunction or the suspension of its functions which results from any of\n" +
        "        the following reasons:\n" +
        "    </p><p data-v-28ae01f9=\"\">\n" +
        "        a) system maintenance or upgrading of Wormhole Wallet;\n" +
        "    </p><p data-v-28ae01f9=\"\">\n" +
        "        b) force majeure, such as typhoon, earthquake, flood, lightning or\n" +
        "        terrorist attack;\n" +
        "    </p><p data-v-28ae01f9=\"\">\n" +
        "        c) malfunction of your computer, mobile device hardware and software, and\n" +
        "        failure of telecommunication lines and power supply lines;\n" +
        "    </p><p data-v-28ae01f9=\"\">\n" +
        "        d) your improper, unauthorized or unrecognized use of Wormhole Wallet;\n" +
        "    </p><p data-v-28ae01f9=\"\">\n" +
        "        e) computer viruses, Trojan horse, malicious program attacks, network\n" +
        "        congestion, system instability, system or equipment failure,\n" +
        "        telecommunication failure, power failure, banking issues, government acts;\n" +
        "        and\n" +
        "    </p><p data-v-28ae01f9=\"\">\n" +
        "        f) any other reasons not caused by Wormhole Wallet.\n" +
        "    </p><p data-v-28ae01f9=\"\">\n" +
        "        Wormhole Wallet shall also not be held liable for any and all liabilities\n" +
        "        caused by any of the following circumstances:\n" +
        "    </p><p data-v-28ae01f9=\"\">\n" +
        "        a) you losing your computers, mobile devices, deleting Wormhole Wallet\n" +
        "        applications and wallets without back-up, forgetting Wallet Passwords,\n" +
        "        Private Keys, Mnemonic Words, without back-up, which result in the loss of\n" +
        "        such User’s tokens;\n" +
        "    </p><p data-v-28ae01f9=\"\">\n" +
        "        b) you disclosing your Wallet Passwords, Private Keys, Mnemonic Words, or\n" +
        "        lending or transferring your Wormhole Wallet to others, or authorizing\n" +
        "        others to use your mobile devices or Wormhole Wallet, or downloading\n" +
        "        Wormhole Wallet applications through unofficial channels, or using Wormhole\n" +
        "        Wallet applications by other insecure means, which result in the loss of\n" +
        "        your tokens;\n" +
        "    </p><p data-v-28ae01f9=\"\">\n" +
        "        c) you mishandling Wormhole Wallet (including but not limited to wrong\n" +
        "        address, failure of the node servers selected by you), which result in the\n" +
        "        loss of tokens;\n" +
        "    </p><p data-v-28ae01f9=\"\">\n" +
        "        d) you being unfamiliar with the knowledge in relation to Blockchain\n" +
        "        technology and your mishandling of Wormhole Wallet resulting in loss of\n" +
        "        your tokens;\n" +
        "    </p><p data-v-28ae01f9=\"\">\n" +
        "        e) Wormhole Wallet being unable to copy accurate transaction records due to\n" +
        "        system delay or Blockchain instability.\n" +
        "    </p><p data-v-28ae01f9=\"\"><strong data-v-28ae01f9=\"\">Article 5</strong></p><p data-v-28ae01f9=\"\">\n" +
        "        You acknowledge and agree that Wormhole Wallet may be used by you and your\n" +
        "        counterparty simultaneously or may have affiliation or other interest\n" +
        "        relationship with the foregoing parties, and you agree to waive any actual\n" +
        "        or potential conflicts of interests and will not claim against Wormhole\n" +
        "        Wallet on such base or burden Wormhole Wallet with more responsibilities or\n" +
        "        duty of care.\n" +
        "    </p><p data-v-28ae01f9=\"\"><strong data-v-28ae01f9=\"\">Article 6</strong></p><p data-v-28ae01f9=\"\">\n" +
        "        Wormhole Wallet is intended for developer testing and it makes no warranty\n" +
        "        and representation that:\n" +
        "    </p><p data-v-28ae01f9=\"\">\n" +
        "        a) your use of Wormhole Wallet would satisfy all your needs or be available\n" +
        "        on an uninterrupted, secure, or error-free basis;\n" +
        "    </p><p data-v-28ae01f9=\"\">\n" +
        "        b) all techniques, products, functions, information or other materials from\n" +
        "        Wormhole Wallet would meet your expectations.\n" +
        "    </p><p data-v-28ae01f9=\"\"><strong data-v-28ae01f9=\"\"></strong></p><p data-v-28ae01f9=\"\"><strong data-v-28ae01f9=\"\">Article 7</strong></p><p data-v-28ae01f9=\"\">\n" +
        "        You hereby acknowledge and agree that:\n" +
        "        <br data-v-28ae01f9=\"\"><br data-v-28ae01f9=\"\"></p><p data-v-28ae01f9=\"\">\n" +
        "        a) Wormhole Wallet provides no services with respect to law, tax, and\n" +
        "        investment. Wormhole Wallet does not offer investment advice or analysis,\n" +
        "        nor does Wormhole Wallet endorse or recommend investment/participation in\n" +
        "        any project launched on Wormhole Wallet’s platform. If needed, you shall\n" +
        "        obtain advices from professional in law, tax, and investment with respect\n" +
        "        to your use of Wormhole Wallet, and Wormhole Wallet is not liable for any\n" +
        "        of your losses, including but not limited to your token loss, monetary loss\n" +
        "        and/or data loss incurred in use of Wormhole Wallet;\n" +
        "    </p><p data-v-28ae01f9=\"\">\n" +
        "        b) You understand that in accordance with the applicable laws, Wormhole\n" +
        "        Wallet may change access standards to users now and then, limiting\n" +
        "        functions range and approaches provided to some particular group of people;\n" +
        "    </p><p data-v-28ae01f9=\"\">\n" +
        "        c) Any content downloaded or otherwise obtained through the use of Wormhole\n" +
        "        Wallet is downloaded at your own risk, and you will be solely responsible\n" +
        "        for any damage to your computer system or mobile system or loss of data\n" +
        "        that results from such download or use of Wormhole Wallet.\n" +
        "    </p><p data-v-28ae01f9=\"\">\n" +
        "        d) Notwithstanding anything to the contrary, the total liability for\n" +
        "        Wormhole Wallet under this Disclaimer shall no exceed the lesser of: a) the\n" +
        "        market value of 0.1 ETH; and b) 10 Singapore Dollars.\n" +
        "    </p><p data-v-28ae01f9=\"\"><strong data-v-28ae01f9=\"\">Article </strong><strong data-v-28ae01f9=\"\">8</strong><strong data-v-28ae01f9=\"\"></strong></p><p data-v-28ae01f9=\"\">\n" +
        "        Any person that directly or indirectly uses Wormhole Wallet shall be deemed\n" +
        "        as having voluntarily accepted this Disclaimer, the Wormhole Wallet Terms\n" +
        "        and any other restrictions announced by Wormhole Wallet from time to time.\n" +
    "    </p></div>"
    

}
