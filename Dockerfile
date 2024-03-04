# Use the Microsoft ASP.NET Core 6 runtime image
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base 
EXPOSE 80
EXPOSE 443
# Set the working directory
WORKDIR /app
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["./ShuttleInfraAPI.csproj", "."]
RUN dotnet restore "ShuttleInfraAPI.csproj"

COPY . .
RUN dotnet build "ShuttleInfraAPI.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "ShuttleInfraAPI.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

# Expose port and start the API
ENTRYPOINT ["dotnet", "ShuttleInfraAPI.dll"]
