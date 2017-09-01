FROM elixir
ENV HOME=/home/elixir
WORKDIR $HOME/connect_four
COPY . $HOME/connect_four
RUN mix deps.get
RUN mix test
ENTRYPOINT ["mix", "run", "-e"]
CMD ["ConnectFour.Controller.start_battle"]
