sshoverssl
----------

Have you ever found yourself in a situation where you want to ssh out of a network that only allows HTTP/HTTPS connections?  Now you can, by tunneling ssh over ssl.

Setup
-----

Put in .ssh/config

.. code-block:: bash
  Host jump
    User jump
    ProxyCommand ~/PATH/TO/sshoverssl/connect.sh
    IdentityFile ~/PATH/TO/sshoverssl/creds/current

  Host *.jump
    ProxyCommand ssh jump -W "$(basename %h .jump):%p"

