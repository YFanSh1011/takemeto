# takemeto

A convenient command line tool for setting up a personal OpenVPN-based VPN infrastructure on AWS, ideal for general use and non-production scale applications.

## Description

`Takemeto` is crafted for individuals and small teams looking to establish a secure, private network connection for their everyday internet activities or developmental projects. This tool allows for the quick and easy deployment of a VPN in various global locations, as defined by the user. Unlike enterprise-scale solutions, `takemeto` is designed with simplicity and accessibility in mind, making it perfect for educational purposes, personal projects, or any general use case where privacy and security are desired without the complexity of large-scale infrastructure management.

## Getting Started

### Dependencies

Ensure you have the following setup before using `takemeto`:

- **AWS CLI**: Properly configured for access to AWS services.
- **Selenium WebDriver**: For automating web interactions during the VPN setup.
- **OpenVPN Client**: Installed on the client machine for VPN connectivity.

### Installing

To get started with `takemeto`, follow these simplified steps:

1. Clone the `takemeto` repository to your machine:

```bash
git clone https://github.com/yourgithub/takemeto.git
cd takemeto
```

2. Configure your AWS CLI if you haven't already, to ensure `takemeto` can provision resources under your account:

```bash
aws configure
```

3. Install the required Python dependencies:

```bash
pip install -r requirements.txt
```

4. Make sure you have Terraform installed in your machine

```bash
terraform -version
```

5. Install [OpenVPN Clients](https://openvpn.net/client/) depending on your architecture of choice

### Configuration

`Takemeto` uses a `.env` file for environment configuration. This file has already been created in the root directory of the project. Simply populate it with your settings.

Ensure you replace the `PUBLIC_KEY_FILEPATH` with the actual path to your OpenVPN public key, and update the `VPN_ADMIN_USERNAME` and `VPN_ADMIN_PASSWORD` with your desired admin credentials.

### Executing Program

```bash
./takemeto.sh <region-alias-name>
```

Note: Replace `<region-alias-name>` with the alias of your chosen region as listed in the `allowed_regions.txt` file. This file contains a list of city names that acts as aliases for their corresponding AWS regions, making it easier to select your desired location.

## Contributing

Contributions to `takemeto` are welcome! Follow these steps to contribute:

1. Fork the project.
2. Create a feature branch (`git checkout -b feature/YourAmazingFeature`).
3. Commit your changes (`git commit -m 'Add some YourAmazingFeature'`).
4. Push to the branch (`git push origin feature/YourAmazingFeature`).
5. Open a pull request.

## Possible Future Enhancements

- **Expanded Web Browser Automation Support**: Aiming to go beyond Chrome, I plan to introduce support for additional browsers such as Firefox, Safari, and Edge. This will provide users with the flexibility to automate web interactions in their preferred browser environment.

- **Integration with Additional Cloud Providers**: While `takemeto` currently supports AWS, diversifying cloud service options is on the agenda. Expanding its capabilities to include Google Cloud Platform (GCP) and Microsoft Azure will allow users to deploy VPN infrastructure on their platform of choice, enhancing versatility.

- **Simultaneous Multi-Region Deployment**: Enhancing `takemeto` to support the setup of VPNs across multiple regions simultaneously is a key goal. This will offer users the ability to create a more resilient and high-performing network infrastructure that spans globally.

- **Customizable Installation Script and Remote User Profile Fetching**: I'm exploring the idea of replacing the existing OpenVPN AMI with a customizable installation script. This would grant users more control over the VPN setup process and allow for a tailored VPN environment. Additionally, incorporating the capability to fetch user profiles remotely would streamline user management and remove the necessity of browser automation.

These potential enhancements are designed to make `takemeto` more powerful, flexible, and suited to a wider range of user needs.

## Acknowledgments

- Thanks to OpenVPN for the secure protocol and the AMI that enables fast setup.
- AWS for their reliable cloud services.
- The creators of Terraform for simplifying infrastructure as code.
