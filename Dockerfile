# Version values referenced from https://hub.docker.com/_/microsoft-dotnet-aspnet

FROM mcr.microsoft.com/dotnet/sdk:8.0-cbl-mariner2.0 AS build


WORKDIR /src
COPY [".", "./"]
ARG TARGETARCH
RUN dotnet build "./src/Service/Azure.DataApiBuilder.Service.csproj" -c Docker -o /out \
    -r $( [ "$TARGETARCH" = "arm64" ] && echo "linux-arm64" || echo "linux-x64" )

FROM mcr.microsoft.com/dotnet/aspnet:8.0-cbl-mariner2.0 AS runtime

COPY --from=build /out /App
# Add default dab-config.json to /App in the image
COPY dab-config.json /App/dab-config.json
WORKDIR /App
ENV ASPNETCORE_URLS=http://+:5000
ENTRYPOINT ["dotnet", "Azure.DataApiBuilder.Service.dll"]
