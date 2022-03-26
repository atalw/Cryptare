# Cryptare

Cryptare is an iOS app that offers multi-portfolio management, customizable alerts, cryptocurrency tracking, and aggregated news. It supports 1000+ cryptocurrencies, 100+ exchanges, and all fiat currencies with data fetched and streamed in real-time.

Cryptare was discontinued in 2018 and is no longer available on the app store. During it's peak it served 500+ users weekly and reached rank 6 on the paid section of the iOS charts.

## Code 

Cryptare consisted of an iOS app built using Swift whose code is available in this repo. In addition, I built a [backend](https://github.com/atalw/cryptare-backend) coded in Python which is linked below.

The iOS app implemented some neat functionality streaming price updates in real-time, supporting multiple cryptocurrencies in a single portfolio, multiple portfolios, and creating price alerts to track your favourite cryptocurrencies. UX-wise there are some fun implementations like sliding tabs, app-wide night mode, and customizable settings for app functionality.

I was in the process of building a standardized API for developers to fetch cryptocurrency stats from 100+ exchanges in all supported fiat currencies. More details about this can found in the [API repo](https://github.com/atalw/cryptare-api). I used Firebase and it's functionality to provide a real-time NoSQL database. Firebase functions was also handy, particularly in allowing the user to set up customizable cryptocurrency price alerts. Code for that is also linked below.

- [API](https://github.com/atalw/cryptare-api)
- [Backend repo](https://github.com/atalw/cryptare-backend)
- [Website repo](https://github.com/atalw/cryptare.io)
- [Firebase functions repo](https://github.com/atalw/cryptare-firebase)


## Marketing Resources

If you're interested in learning more about Cryptare, here are some marketing resources that I built and used at the time.
- [Website](http://akshittalwar.com/cryptare.io/)
- [Cryptare (2018) Producthunt](https://www.producthunt.com/posts/cryptare-for-ios)
- [Cryptare (2017) Producthunt](https://www.producthunt.com/posts/cryptare)
- [Youtube demo video](https://www.youtube.com/watch?v=V7Pqoy11aLE)

## Licensing

Cryptare is released under the MIT license. Contributing to the open-source ecosystem built around cryptocurrencies, and in general, feels good. Enjoy! 
