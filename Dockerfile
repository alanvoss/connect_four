FROM elixir
ENV HOME=/home/elixir
RUN mix local.hex --force
WORKDIR $HOME/connect_four
COPY . $HOME/connect_four
RUN mix deps.get
RUN mix test
ENTRYPOINT ["mix", "run", "-e"]
CMD ["ConnectFour.Controller.start_battle"]
